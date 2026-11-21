import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  // Modos: Iniciar Sesión vs Registrarse
  bool _esRegistro = false;

  // Rol seleccionado: Cliente vs Taller
  RolUsuario _rolSeleccionado = RolUsuario.cliente;

  // Controladores de texto
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Controladores exclusivos para registro de Taller nuevo
  final _ciudadCtrl = TextEditingController(text: 'Lima');
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ciudadCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final nombre = _nombreCtrl.text.trim();

    try {
      if (_esRegistro) {
        await auth.registrarUsuario(
          nombre: nombre.isNotEmpty
              ? nombre
              : (_rolSeleccionado == RolUsuario.cliente ? 'Cliente SORA' : 'Mi Taller Textil'),
          email: email,
          password: password,
          rol: _rolSeleccionado,
          ciudad: _ciudadCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
        );
      } else {
        await auth.iniciarSesion(
          email: email,
          password: password,
          rol: _rolSeleccionado,
        );
      }

      if (!mounted) return;

      // Redirigir según el rol seleccionado
      if (_rolSeleccionado == RolUsuario.taller) {
        context.go(SoraRoutes.tallerSolicitudes);
      } else {
        context.go(SoraRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar: $e'),
          backgroundColor: SoraColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _entrarComoInvitado() {
    final auth = context.read<AuthProvider>();
    auth.cambiarRol(RolUsuario.cliente);
    context.go(SoraRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoraColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header / Logo ──────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [SoraColors.primary, SoraColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: SoraColors.primary.withAlpha(80),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.checkroom, color: Colors.white, size: 38),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'SORA',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: SoraColors.onBackground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Confección textil y talleres a tu medida',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: SoraColors.onBackground.withAlpha(160),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Selector de Modo: Iniciar Sesión / Registro ─────────────
                    Container(
                      decoration: BoxDecoration(
                        color: SoraColors.cardBorder.withAlpha(100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _BotonPestana(
                              activo: !_esRegistro,
                              titulo: 'Iniciar Sesión',
                              onTap: () => setState(() => _esRegistro = false),
                            ),
                          ),
                          Expanded(
                            child: _BotonPestana(
                              activo: _esRegistro,
                              titulo: 'Crear Cuenta',
                              onTap: () => setState(() => _esRegistro = true),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Selector de Tipo de Usuario / Rol ──────────────────────
                    const Text(
                      '¿Cómo deseas ingresar hoy?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: SoraColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _CardRol(
                            icono: Icons.person_outline,
                            titulo: 'Soy Cliente',
                            subtitulo: 'Diseña y cotiza prendas',
                            seleccionado: _rolSeleccionado == RolUsuario.cliente,
                            onTap: () => setState(() => _rolSeleccionado = RolUsuario.cliente),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CardRol(
                            icono: Icons.storefront_outlined,
                            titulo: 'Soy Taller',
                            subtitulo: 'Gestiona confección',
                            seleccionado: _rolSeleccionado == RolUsuario.taller,
                            onTap: () => setState(() => _rolSeleccionado = RolUsuario.taller),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Campos de Formulario ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: SoraColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SoraColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CAMPOS EXCLUSIVOS DE REGISTRO (CREAR CUENTA)
                          if (_esRegistro) ...[
                            Text(
                              _rolSeleccionado == RolUsuario.taller ? 'Nombre de tu Taller Textil' : 'Nombre Completo',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nombreCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  _rolSeleccionado == RolUsuario.taller ? Icons.store : Icons.person,
                                  color: SoraColors.primary,
                                  size: 20,
                                ),
                                hintText: _rolSeleccionado == RolUsuario.taller ? 'Ej. Confecciones San Martín' : 'Ej. María Pérez',
                                filled: true,
                                fillColor: SoraColors.background.withAlpha(120),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return _rolSeleccionado == RolUsuario.taller
                                      ? 'Por favor ingresa el nombre de tu taller'
                                      : 'Por favor ingresa tu nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Si se registra como TALLER: Ciudad, Dirección, Teléfono
                            if (_rolSeleccionado == RolUsuario.taller) ...[
                              const Text(
                                'Ciudad / Departamento',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _ciudadCtrl,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.location_city, color: SoraColors.primary, size: 20),
                                  hintText: 'Ej. Lima, Arequipa, Trujillo...',
                                  filled: true,
                                  fillColor: SoraColors.background.withAlpha(120),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu ciudad' : null,
                              ),
                              const SizedBox(height: 14),

                              const Text(
                                'Dirección o Zona del Taller',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _direccionCtrl,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.place_outlined, color: SoraColors.primary, size: 20),
                                  hintText: 'Ej. Av. Gamarra 450, La Victoria',
                                  filled: true,
                                  fillColor: SoraColors.background.withAlpha(120),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la dirección de tu taller' : null,
                              ),
                              const SizedBox(height: 14),

                              const Text(
                                'Teléfono / WhatsApp de Contacto',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _telefonoCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.phone_outlined, color: SoraColors.primary, size: 20),
                                  hintText: 'Ej. +51 987 654 321',
                                  filled: true,
                                  fillColor: SoraColors.background.withAlpha(120),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu teléfono' : null,
                              ),
                              const SizedBox(height: 14),
                            ],
                          ],

                          // CAMPOS COMUNES: CORREO Y CONTRASEÑA
                          const Text(
                            'Correo Electrónico',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: SoraColors.primary, size: 20),
                              hintText: _rolSeleccionado == RolUsuario.taller ? 'contacto@mitaller.pe' : 'usuario@gmail.com',
                              filled: true,
                              fillColor: SoraColors.background.withAlpha(120),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                              if (!val.contains('@') || !val.contains('.')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Contraseña
                          const Text(
                            'Contraseña',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: SoraColors.primary, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  size: 18,
                                  color: SoraColors.outline,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              hintText: '••••••••',
                              filled: true,
                              fillColor: SoraColors.background.withAlpha(120),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            validator: (val) {
                              if (val == null || val.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Botón Principal de Acción ──────────────────────────────
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: SoraColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _esRegistro ? Icons.business : Icons.login,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _esRegistro
                                        ? (_rolSeleccionado == RolUsuario.cliente
                                            ? 'Crear Cuenta de Cliente'
                                            : 'Registrar mi Taller Textil')
                                        : (_rolSeleccionado == RolUsuario.cliente
                                            ? 'Entrar como Cliente'
                                            : 'Entrar al Panel de Taller'),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Opción de Explorar como Invitado ───────────────────────
                    TextButton(
                      onPressed: _entrarComoInvitado,
                      child: Text(
                        'Continuar como invitado sin registrarse',
                        style: TextStyle(
                          color: SoraColors.onBackground.withAlpha(180),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonPestana extends StatelessWidget {
  final bool activo;
  final String titulo;
  final VoidCallback onTap;

  const _BotonPestana({
    required this.activo,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: activo ? SoraColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: activo ? FontWeight.bold : FontWeight.w500,
              color: activo ? SoraColors.primary : SoraColors.onBackground.withAlpha(160),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardRol extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const _CardRol({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: seleccionado ? SoraColors.surface : SoraColors.surface.withAlpha(140),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? SoraColors.primary : SoraColors.cardBorder,
            width: seleccionado ? 2.0 : 1.0,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: SoraColors.primary.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: seleccionado ? SoraColors.primary.withAlpha(20) : SoraColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 24,
                color: seleccionado ? SoraColors.primary : SoraColors.onBackground.withAlpha(160),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: seleccionado ? SoraColors.primary : SoraColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: SoraColors.onBackground.withAlpha(140),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
