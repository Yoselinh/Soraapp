import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Pantalla de detalle de un taller de confección
class TallerDetalleScreen extends StatelessWidget {
  final Taller taller;

  const TallerDetalleScreen({super.key, required this.taller});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SoraColors.background,
      appBar: AppBar(
        backgroundColor: SoraColors.background,
        title: Text(taller.nombre),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del taller
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: SoraColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SoraColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: SoraColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.storefront, color: SoraColors.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taller.nombre,
                                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8D7060)),
                                      Text(' ${taller.ciudad}', style: tt.bodySmall),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: taller.esNuevo ? const Color(0xFF10B981) : const Color(0xFFF6C324),
                                      ),
                                      Text(
                                        taller.esNuevo
                                            ? ' Nuevo'
                                            : ' ${taller.calificacion.toStringAsFixed(1)} (${taller.totalCalificaciones} opiniones)',
                                        style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _InfoColumna(label: 'Plazo de entrega', valor: '${taller.plazoDias} días', icono: Icons.schedule)),
                            Expanded(child: _InfoColumna(label: 'Precio base', valor: 'S/.${taller.tablaPrecios.precioBase.toStringAsFixed(0)}', icono: Icons.sell_outlined)),
                            Expanded(child: _InfoColumna(label: 'Trabajos hechos', valor: '+${taller.pedidosCompletados}', icono: Icons.check_circle_outline)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  Text('Acerca del taller', style: tt.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SoraColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: SoraColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taller.descripcion,
                          style: tt.bodyMedium?.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.pin_drop_outlined, size: 16, color: SoraColors.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Text(taller.direccion, style: const TextStyle(fontSize: 12, color: Color(0xFF5D4038)))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: SoraColors.primary),
                            const SizedBox(width: 6),
                            Text(taller.telefono, style: const TextStyle(fontSize: 12, color: Color(0xFF5D4038))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Técnicas disponibles
                  Text('Técnicas de confección', style: tt.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: taller.tecnicas.map((tec) {
                      return Container(
                        constraints: const BoxConstraints(minWidth: 140),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SoraColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SoraColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tec.icono, color: SoraColors.primary, size: 24),
                            const SizedBox(height: 6),
                            Text(tec.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: SoraColors.primary)),
                            const SizedBox(height: 2),
                            Text(tec.descripcion, style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060))),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Prendas que confeccionan
                  Text('Prendas que confeccionan', style: tt.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: taller.prendas.map((prenda) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: SoraColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SoraColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(prenda.icono, size: 18, color: SoraColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              prenda.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: SoraColors.onBackground,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Botón inferior fijo: Cotizar con este taller
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: const BoxDecoration(
              color: SoraColors.background,
              border: Border(top: BorderSide(color: SoraColors.cardBorder)),
            ),
            child: FilledButton.icon(
              onPressed: () => _cotizarConEsteTaller(context),
              icon: const Icon(Icons.request_quote_outlined),
              label: const Text('Cotizar con este taller'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cotizarConEsteTaller(BuildContext context) {
    context.read<DisenadorProvider>().preseleccionarTaller(taller);
    Navigator.of(context).pop();
    context.go(SoraRoutes.disenador);
  }
}

class _InfoColumna extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;

  const _InfoColumna({required this.label, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icono, size: 20, color: SoraColors.primary),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: SoraColors.onBackground)),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060))),
      ],
    );
  }
}
