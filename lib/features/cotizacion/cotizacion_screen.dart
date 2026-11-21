import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/features/cotizacion/cotizacion_provider.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Pantalla de comparación de cotizaciones por taller
class CotizacionScreen extends StatelessWidget {
  const CotizacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cotProvider = context.watch<CotizacionProvider>();
    final cotizaciones = cotProvider.cotizaciones;
    final orden = cotProvider.orden;

    return Scaffold(
      backgroundColor: SoraColors.background,
      appBar: AppBar(
        backgroundColor: SoraColors.background,
        title: const Text('Cotización aproximada'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('Ordenar por:', style: tt.bodySmall),
                  const SizedBox(width: 8),
                  _ChipOrden(label: 'Precio', activo: orden == OrdenCotizacion.precio, onTap: () => cotProvider.cambiarOrden(OrdenCotizacion.precio)),
                  const SizedBox(width: 6),
                  _ChipOrden(label: 'Plazo', activo: orden == OrdenCotizacion.plazo, onTap: () => cotProvider.cambiarOrden(OrdenCotizacion.plazo)),
                  const SizedBox(width: 6),
                  _ChipOrden(label: 'Calificación', activo: orden == OrdenCotizacion.calificacion, onTap: () => cotProvider.cambiarOrden(OrdenCotizacion.calificacion)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: SoraColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SoraColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 18, color: SoraColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${cotizaciones.isNotEmpty ? cotizaciones.first.totalUnidades : 0} prendas · ',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(context.read<DisenadorProvider>().diseno.prenda.label, style: tt.bodySmall),
                  const Spacer(),
                  Text('${cotizaciones.length} talleres', style: tt.bodySmall?.copyWith(color: SoraColors.primary, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          Expanded(
            child: cotizaciones.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store_mall_directory_outlined, size: 54, color: Color(0xFF8D7060)),
                          const SizedBox(height: 14),
                          Text(
                            'Ningún taller disponible',
                            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No hay talleres registrados que confeccionen ${context.read<DisenadorProvider>().diseno.prenda.label} por el momento.',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium?.copyWith(color: const Color(0xFF8D7060)),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () => context.go(SoraRoutes.disenador),
                            icon: const Icon(Icons.edit),
                            label: const Text('Elegir otra prenda'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: cotizaciones.length,
                    itemBuilder: (context, index) {
                      final cot = cotizaciones[index];
                      return _TarjetaTaller(
                        cotizacion: cot,
                        destacado: index == 0 && orden == OrdenCotizacion.precio,
                        posicion: index + 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChipOrden extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _ChipOrden({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: activo ? SoraColors.primary : SoraColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? SoraColors.primary : SoraColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: activo ? Colors.white : SoraColors.onBackground),
        ),
      ),
    );
  }
}

class _TarjetaTaller extends StatelessWidget {
  final Cotizacion cotizacion;
  final bool destacado;
  final int posicion;

  const _TarjetaTaller({required this.cotizacion, required this.destacado, required this.posicion});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final taller = cotizacion.taller;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: destacado ? SoraColors.primary : SoraColors.cardBorder,
          width: destacado ? 2 : 1,
        ),
        boxShadow: destacado
            ? [BoxShadow(color: SoraColors.primary.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: destacado ? SoraColors.primary : SoraColors.cardBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#$posicion',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: destacado ? Colors.white : const Color(0xFF8D7060)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(taller.nombre, style: tt.titleMedium)),
                          if (destacado) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: SoraColors.primary, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Mejor precio', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF8D7060)),
                          Text(taller.ciudad, style: tt.bodySmall),
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 13, color: taller.esNuevo ? const Color(0xFF10B981) : const Color(0xFFF6C324)),
                          Text(
                            taller.esNuevo ? ' Nuevo' : ' ${taller.calificacion.toStringAsFixed(1)}',
                            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _MetricaTaller(label: 'Por unidad', valor: 'S/.${cotizacion.precioPorUnidad.toStringAsFixed(2)}'),
                const SizedBox(width: 8),
                _MetricaTaller(label: 'Plazo', valor: '${taller.plazoDias} días'),
                const SizedBox(width: 8),
                _MetricaTaller(label: 'TOTAL', valor: 'S/.${cotizacion.total.toStringAsFixed(2)}', destacado: true),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
            child: Text(taller.descripcion, style: tt.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: FilledButton(
              onPressed: () => _confirmarPedido(context, cotizacion),
              style: FilledButton.styleFrom(
                backgroundColor: destacado ? SoraColors.primary : SoraColors.onBackground,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Elegir este taller'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarPedido(BuildContext context, Cotizacion cotizacion) {
    final notasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SoraColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.send_outlined, color: SoraColors.primary),
            SizedBox(width: 8),
            Text('Enviar Solicitud al Taller'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Taller: ${cotizacion.taller.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Total estimado: S/.${cotizacion.total.toStringAsFixed(2)}'),
              Text('Plazo estimado: ${cotizacion.taller.plazoDias} días hábiles'),
              const SizedBox(height: 14),
              const Text(
                'Instrucciones o notas para el taller (opcional):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notasCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ej. Bordado en hilo dorado, entrega urgente...',
                  filled: true,
                  fillColor: SoraColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SoraColors.primary),
            onPressed: () {
              final notas = notasCtrl.text.trim();
              Navigator.of(ctx).pop();
              final disenadorProvider = context.read<DisenadorProvider>();
              final cotProvider = context.read<CotizacionProvider>();
              final auth = context.read<AuthProvider>();
              final dist = cotProvider.distribucion;

              final pedido = Pedido(
                id: 'PED-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                clienteEmail: auth.emailUsuario,
                clienteNombre: auth.nombreUsuario,
                notas: notas,
                diseno: disenadorProvider.diseno,
                items: dist.cantidades.entries
                    .where((e) => e.value > 0)
                    .map((e) => PedidoItem(talla: e.key, cantidad: e.value))
                    .toList(),
                cotizacion: cotizacion,
                estado: EstadoPedido.cotizado,
                fechaCreacion: DateTime.now(),
              );

              PedidosRepository.instance.agregarPedido(pedido);
              disenadorProvider.reiniciar();
              cotProvider.reiniciar();
              context.go(SoraRoutes.pedidos);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('¡Solicitud enviada a ${cotizacion.taller.nombre}! El taller la revisará para iniciar producción.'),
                      ),
                    ],
                  ),
                  backgroundColor: SoraColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}

class _MetricaTaller extends StatelessWidget {
  final String label;
  final String valor;
  final bool destacado;

  const _MetricaTaller({required this.label, required this.valor, this.destacado = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: destacado ? SoraColors.primary.withValues(alpha: 0.10) : SoraColors.cardBorder.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: destacado ? Border.all(color: SoraColors.primary.withValues(alpha: 0.3)) : null,
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: destacado ? 15 : 13, color: destacado ? SoraColors.primary : SoraColors.onBackground),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060))),
          ],
        ),
      ),
    );
  }
}
