import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/cotizacion/cotizacion_provider.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/data/pedidos_repository.dart';

/// Pantalla de distribución de tallas antes de cotizar
class DistribucionTallasScreen extends StatelessWidget {
  const DistribucionTallasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cotProvider = context.watch<CotizacionProvider>();
    final dist = cotProvider.distribucion;

    return Scaffold(
      backgroundColor: SoraColors.background,
      appBar: AppBar(
        backgroundColor: SoraColors.background,
        title: const Text('Distribución de tallas'),
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SoraColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SoraColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: SoraColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Indica cuántas prendas necesitas por talla. El precio total se calculará en base a la cantidad total.',
                            style: tt.bodySmall?.copyWith(color: const Color(0xFF5D4038)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Cantidad por talla', style: tt.headlineSmall),
                  const SizedBox(height: 16),
                  ...Talla.values.map((talla) {
                    final cantidad = dist.cantidades[talla] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cantidad > 0 ? SoraColors.primary.withValues(alpha: 0.08) : SoraColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cantidad > 0 ? SoraColors.primary.withValues(alpha: 0.4) : SoraColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cantidad > 0 ? SoraColors.primary : SoraColors.cardBorder.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                talla.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: cantidad > 0 ? Colors.white : const Color(0xFF8D7060),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${talla.name} – ${_tallaNombre(talla)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: cantidad > 0 ? SoraColors.primary : SoraColors.onBackground,
                              ),
                            ),
                          ),
                          _Contador(
                            valor: cantidad,
                            onDecrement: cantidad > 0
                                ? () => context.read<CotizacionProvider>().actualizarCantidad(talla, cantidad - 1)
                                : null,
                            onIncrement: () => context.read<CotizacionProvider>().actualizarCantidad(talla, cantidad + 1),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SoraColors.onBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total de prendas:', style: tt.titleMedium?.copyWith(color: Colors.white)),
                        Text(
                          '${dist.totalUnidades}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: SoraColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: const BoxDecoration(
              color: SoraColors.background,
              border: Border(top: BorderSide(color: SoraColors.cardBorder)),
            ),
            child: FilledButton.icon(
              onPressed: dist.totalUnidades > 0
                  ? () {
                      final disenadorProv = context.read<DisenadorProvider>();
                      final diseno = disenadorProv.diseno;
                      final cotProv = context.read<CotizacionProvider>();

                      if (disenadorProv.tieneTallerPreseleccionado) {
                        // Taller ya elegido → cotizar directamente y guardar pedido
                        final taller = disenadorProv.tallerPreseleccionado!;
                        cotProv.cotizarConTallerEspecifico(taller, diseno);
                        final cotizacion = cotProv.cotizaciones.first;

                        final pedido = Pedido(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          diseno: diseno,
                          items: dist.cantidades.entries
                              .where((e) => e.value > 0)
                              .map((e) => PedidoItem(talla: e.key, cantidad: e.value))
                              .toList(),
                          cotizacion: cotizacion,
                          estado: EstadoPedido.cotizado,
                          fechaCreacion: DateTime.now(),
                        );

                        PedidosRepository.instance.agregarPedido(pedido);
                        disenadorProv.reiniciar();
                        disenadorProv.limpiarTallerPreseleccionado();
                        cotProv.reiniciar();
                        context.go(SoraRoutes.pedidos);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Cotización con ${taller.nombre} guardada'),
                                ),
                              ],
                            ),
                            backgroundColor: SoraColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else {
                        // Sin taller preseleccionado → mostrar lista de talleres
                        cotProv.calcularCotizaciones(diseno);
                        context.push(SoraRoutes.cotizacion);
                      }
                    }
                  : null,
              icon: const Icon(Icons.search),
              label: Text(
                dist.totalUnidades > 0
                    ? 'Solicitar cotización (${dist.totalUnidades} prendas)'
                    : 'Agrega al menos 1 prenda',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _tallaNombre(Talla t) {
    switch (t) {
      case Talla.XS: return 'Extra pequeño';
      case Talla.S: return 'Pequeño';
      case Talla.M: return 'Mediano';
      case Talla.L: return 'Grande';
      case Talla.XL: return 'Extra grande';
      case Talla.XXL: return 'Doble extra grande';
    }
  }
}

class _Contador extends StatelessWidget {
  final int valor;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _Contador({required this.valor, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BtnContador(icono: Icons.remove, onTap: onDecrement, activo: onDecrement != null),
        SizedBox(
          width: 40,
          child: Center(
            child: Text('$valor', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: SoraColors.onBackground)),
          ),
        ),
        _BtnContador(icono: Icons.add, onTap: onIncrement, activo: true),
      ],
    );
  }
}

class _BtnContador extends StatelessWidget {
  final IconData icono;
  final VoidCallback? onTap;
  final bool activo;

  const _BtnContador({required this.icono, required this.onTap, required this.activo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: activo ? SoraColors.primary : SoraColors.cardBorder,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, color: Colors.white, size: 18),
      ),
    );
  }
}
