import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Pantalla de Perfil y Ajustes del Taller
class PerfilTallerScreen extends StatelessWidget {
  const PerfilTallerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();
    final repo = context.watch<PedidosRepository>();
    final taller = auth.tallerActivo;

    final solicitudes = repo.solicitudesPendientesPorTaller(taller.id).length;
    final enProduccion = repo.enProduccionPorTaller(taller.id).length;
    final ingresos = repo.ingresosTotalesTaller(taller.id);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjeta Principal del Taller
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [SoraColors.primary, SoraColors.primary.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: SoraColors.primary.withAlpha(60),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.storefront, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taller.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${taller.ciudad} · Taller Verificado',
                            style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoRowBlanca(
                      icono: Icons.star,
                      texto: taller.esNuevo ? 'Nuevo' : '${taller.calificacion.toStringAsFixed(1)} / 5.0',
                    ),
                    _InfoRowBlanca(icono: Icons.check_circle, texto: '${taller.pedidosCompletados} entregados'),
                    _InfoRowBlanca(icono: Icons.timer, texto: '${taller.plazoDias} días'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Métricas en Vivo del Taller
          Text('Rendimiento del Taller', style: tt.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricaCard(
                  titulo: 'Ingresos',
                  valor: 'S/. ${ingresos.toStringAsFixed(0)}',
                  icono: Icons.monetization_on_outlined,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricaCard(
                  titulo: 'En Confección',
                  valor: '$enProduccion',
                  icono: Icons.precision_manufacturing_outlined,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricaCard(
                  titulo: 'Por Cotizar',
                  valor: '$solicitudes',
                  icono: Icons.inbox_outlined,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Selector de Taller Simulado (para pruebas del evaluador)
          Text('Simular Otro Taller (Demostración)', style: tt.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Puedes cambiar a cualquiera de los 6 talleres registrados para ver cómo cambia la información:',
            style: tt.bodySmall?.copyWith(color: SoraColors.disabled),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: SoraColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SoraColors.disabled.withAlpha(60)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: taller.id,
                items: auth.talleresDisponibles.map((t) {
                  return DropdownMenuItem<String>(
                    value: t.id,
                    child: Text('${t.nombre} (${t.ciudad})'),
                  );
                }).toList(),
                onChanged: (nuevoId) {
                  if (nuevoId != null) {
                    auth.seleccionarTaller(nuevoId);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Información de Contacto
          Text('Información de Contacto', style: tt.titleMedium),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: SoraColors.primary),
                  title: const Text('Dirección física'),
                  subtitle: Text(taller.direccion),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: SoraColors.primary),
                  title: const Text('Teléfono comercial'),
                  subtitle: Text(taller.telefono),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: SoraColors.primary),
                  title: const Text('Correo electrónico'),
                  subtitle: Text(auth.emailUsuario),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          // Botón destacado: Cambiar a Modo Cliente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SoraColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SoraColors.primary.withAlpha(40)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.switch_account, color: SoraColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '¿Quieres comprar o diseñar prendas?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cambia de vuelta al Modo Cliente para explorar talleres, diseñar prendas en el canvas 3D y solicitar nuevas cotizaciones.',
                  style: TextStyle(fontSize: 12, color: SoraColors.disabled),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SoraColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver al Modo Cliente'),
                    onPressed: () {
                      auth.cambiarRol(RolUsuario.cliente);
                      context.go('/');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SoraColors.error,
                      side: const BorderSide(color: SoraColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión del taller'),
                    onPressed: () {
                      auth.cerrarSesion();
                      context.go(SoraRoutes.auth);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoRowBlanca extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _InfoRowBlanca({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 16, color: Colors.amberAccent),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SoraColors.disabled.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: const TextStyle(fontSize: 11, color: SoraColors.disabled),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
