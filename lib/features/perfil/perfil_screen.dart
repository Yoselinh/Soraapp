import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/features/cotizacion/cotizacion_provider.dart';
import 'package:sora_app/providers/auth_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = 'Usuario SORA';
  String _email = 'usuario@sora.pe';
  bool _notificaciones = true;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nombre = auth.nombreUsuario;
    _email = auth.emailUsuario;
  }

  // ── Avatar con inicial ──────────────────────────────────────────────────────
  String get _inicial => _nombre.trim().isNotEmpty ? _nombre.trim()[0].toUpperCase() : 'U';

  // ── Editar nombre / email ───────────────────────────────────────────────────
  Future<void> _editarCampo({
    required String titulo,
    required String valorActual,
    required ValueChanged<String> onGuardado,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final ctrl = TextEditingController(text: valorActual);
    final resultado = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SoraColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(titulo),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: titulo,
            filled: true,
            fillColor: SoraColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (resultado != null && resultado.isNotEmpty) {
      onGuardado(resultado);
    }
  }

  // ── Cerrar sesión ───────────────────────────────────────────────────────────
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SoraColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Se reiniciará el estado de la app. Tus pedidos de esta sesión se perderán.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: SoraColors.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      context.read<DisenadorProvider>().reiniciar();
      context.read<CotizacionProvider>().reiniciar();
      context.read<AuthProvider>().cerrarSesion();
      setState(() {
        _nombre = 'Usuario SORA';
        _email = 'usuario@sora.pe';
        _notificaciones = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 8),
              Text('Sesión cerrada'),
            ],
          ),
          backgroundColor: SoraColors.onBackground,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.go(SoraRoutes.auth);
    }
  }

  // ── Acerca de SORA ──────────────────────────────────────────────────────────
  void _mostrarAcercaDe() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SoraColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: SoraColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.checkroom, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'SORA',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: SoraColors.primary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versión 1.0.0 (beta)',
              style: TextStyle(fontSize: 13, color: Color(0xFF8D7060)),
            ),
            const SizedBox(height: 16),
            const Text(
              'SORA es una plataforma para diseñar prendas personalizadas y conectar con talleres de confección en todo el Perú. Personaliza tu prenda paso a paso, compara cotizaciones y haz tu pedido en minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF5D4038)),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.place_outlined, size: 16, color: SoraColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Hecho en Perú 🇵🇪',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Ayuda y soporte ─────────────────────────────────────────────────────────
  void _mostrarAyuda() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoraColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: SoraColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Ayuda y Soporte',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: SoraColors.onBackground),
            ),
            const SizedBox(height: 16),
            ..._faq.map((item) => _FaqItem(pregunta: item['q']!, respuesta: item['a']!)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SoraColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SoraColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contacto directo',
                    style: TextStyle(fontWeight: FontWeight.w700, color: SoraColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: SoraColors.primary),
                      SizedBox(width: 8),
                      Text('soporte@sora.pe', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 16, color: SoraColors.primary),
                      SizedBox(width: 8),
                      Text('+51 987 654 321', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _faq = [
    {
      'q': '¿Cómo diseño mi prenda?',
      'a': 'Ve a la pestaña "Diseñar", sigue los 6 pasos (prenda, colores, corte, logo, tela y detalles) y al final presiona "Ver mi diseño".',
    },
    {
      'q': '¿Cómo elijo un taller?',
      'a': 'Puedes explorar talleres en la pestaña "Talleres" y preseleccionar uno antes de cotizar, o dejar que SORA compare todos automáticamente.',
    },
    {
      'q': '¿Qué significa "Cotizado" vs "Confirmado"?',
      'a': '"Cotizado" significa que el pedido fue generado con un taller preseleccionado. "Confirmado" indica que elegiste ese taller después de comparar los precios.',
    },
    {
      'q': '¿Los precios son exactos?',
      'a': 'Los precios son aproximaciones calculadas en base al tipo de prenda, tela, extras y técnica de personalización. El taller puede ajustarlos al confirmar el pedido.',
    },
    {
      'q': '¿Puedo cancelar un pedido?',
      'a': 'Por el momento la app es una versión demo. El historial de pedidos se guarda solo durante la sesión activa.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Consumer<PedidosRepository>(
      builder: (context, repo, _) {
        final pedidos = repo.pedidos;
        final totalPedidos = pedidos.length;
        final confirmados = pedidos.where((p) => p.estado == EstadoPedido.confirmado).length;
        final cotizados = pedidos.where((p) => p.estado == EstadoPedido.cotizado).length;
        final totalGastado = pedidos
            .where((p) => p.estado == EstadoPedido.confirmado)
            .fold(0.0, (sum, p) => sum + p.cotizacion.total);

        return Scaffold(
          backgroundColor: SoraColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ── Cabecera con gradiente ──────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SoraColors.primary.withValues(alpha: 0.15),
                        SoraColors.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar con inicial
                      GestureDetector(
                        onTap: () => _editarCampo(
                          titulo: 'Editar nombre',
                          valorActual: _nombre,
                          onGuardado: (v) {
                            setState(() => _nombre = v);
                            context.read<AuthProvider>().actualizarDatosUsuario(nombre: v);
                          },
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: SoraColors.primary,
                              child: Text(
                                _inicial,
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: SoraColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: SoraColors.cardBorder, width: 1.5),
                              ),
                              child: const Icon(Icons.edit, size: 14, color: SoraColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Nombre editable
                      GestureDetector(
                        onTap: () => _editarCampo(
                          titulo: 'Editar nombre',
                          valorActual: _nombre,
                          onGuardado: (v) {
                            setState(() => _nombre = v);
                            context.read<AuthProvider>().actualizarDatosUsuario(nombre: v);
                          },
                        ),
                        child: Text(
                          _nombre,
                          style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email editable
                      GestureDetector(
                        onTap: () => _editarCampo(
                          titulo: 'Editar email',
                          valorActual: _email,
                          keyboardType: TextInputType.emailAddress,
                          onGuardado: (v) {
                            setState(() => _email = v);
                            context.read<AuthProvider>().actualizarDatosUsuario(email: v);
                          },
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _email,
                              style: tt.bodyMedium?.copyWith(color: const Color(0xFF8D7060)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit, size: 12, color: Color(0xFF8D7060)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Estadísticas ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: SoraColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SoraColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        _StatItem(valor: '$totalPedidos', label: 'Pedidos'),
                        _Divider(),
                        _StatItem(valor: '$confirmados', label: 'Confirmados'),
                        _Divider(),
                        _StatItem(valor: '$cotizados', label: 'Cotizados'),
                        _Divider(),
                        _StatItem(
                          valor: totalGastado > 0
                              ? 'S/.${totalGastado.toStringAsFixed(0)}'
                              : 'S/.0',
                          label: 'Invertido',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Opciones del perfil ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'Mi actividad'),
                      const SizedBox(height: 8),
                      _PerfilItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Mis pedidos',
                        trailing: totalPedidos > 0
                            ? _Badge(texto: '$totalPedidos')
                            : null,
                        onTap: () => context.go(SoraRoutes.pedidos),
                      ),
                      _PerfilItem(
                        icon: Icons.edit_note_outlined,
                        label: 'Ir al diseñador',
                        onTap: () => context.go(SoraRoutes.disenador),
                      ),
                      _PerfilItem(
                        icon: Icons.storefront_outlined,
                        label: 'Explorar talleres',
                        onTap: () => context.go(SoraRoutes.talleres),
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Preferencias'),
                      const SizedBox(height: 8),
                      // Toggle de notificaciones
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: SoraColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: SoraColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_outlined, color: SoraColors.primary),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Notificaciones',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ),
                            Switch(
                              value: _notificaciones,
                              onChanged: (v) => setState(() => _notificaciones = v),
                              activeThumbColor: SoraColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Rol de Usuario'),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SoraColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: SoraColors.primary.withAlpha(50)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: SoraColors.primary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.storefront, color: SoraColors.primary, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    '¿Tienes un taller de confección?',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Ingresa al panel del taller para gestionar cotizaciones recibidas, actualizar avances de producción y configurar tu tarifario.',
                              style: TextStyle(fontSize: 12, color: SoraColors.disabled),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: SoraColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.business_center_outlined, size: 18),
                                label: const Text('Acceso para Talleres'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: SoraColors.surface,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.lock_outline, color: SoraColors.primary),
                                          SizedBox(width: 8),
                                          Text('Cuenta de Taller'),
                                        ],
                                      ),
                                      content: const Text(
                                        'Actualmente estás conectado como Cliente.\n\nPara ingresar al panel de gestión y tarifario, debes iniciar sesión con una cuenta de Taller Textil.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(backgroundColor: SoraColors.primary),
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                            context.read<AuthProvider>().cerrarSesion();
                                            context.go(SoraRoutes.auth);
                                          },
                                          child: const Text('Cambiar a Cuenta Taller'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionLabel(label: 'Información'),
                      const SizedBox(height: 8),
                      _PerfilItem(
                        icon: Icons.help_outline,
                        label: 'Ayuda y soporte',
                        onTap: _mostrarAyuda,
                      ),
                      _PerfilItem(
                        icon: Icons.info_outline,
                        label: 'Acerca de SORA',
                        onTap: _mostrarAcercaDe,
                      ),
                      const SizedBox(height: 20),
                      // Cerrar sesión
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _cerrarSesion,
                          icon: const Icon(Icons.logout, color: SoraColors.error),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: SoraColors.error, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: SoraColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Widgets auxiliares ──────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String valor;
  final String label;
  const _StatItem({required this.valor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: SoraColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: SoraColors.cardBorder);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8D7060),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  const _Badge({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SoraColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class _PerfilItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PerfilItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SoraColors.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: SoraColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: SoraColors.disabled),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String pregunta;
  final String respuesta;
  const _FaqItem({required this.pregunta, required this.respuesta});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: SoraColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SoraColors.cardBorder),
      ),
      child: InkWell(
        onTap: () => setState(() => _expandido = !_expandido),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.pregunta,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expandido ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: SoraColors.primary),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.respuesta,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5D4038), height: 1.5),
                  ),
                ),
                crossFadeState: _expandido ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
