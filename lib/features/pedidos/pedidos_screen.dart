import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/providers/auth_provider.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: Consumer<PedidosRepository>(
        builder: (context, repo, _) {
          // Filtrar únicamente los pedidos pertenecientes al cliente actual
          final pedidos = repo.pedidosPorCliente(auth.emailUsuario);
          if (pedidos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: SoraColors.disabled),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes pedidos',
                    style: tt.headlineSmall?.copyWith(color: SoraColors.disabled),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diseña una prenda y solicita tu primera cotización',
                    style: tt.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _mostrarDetallePedido(context, pedido),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(pedido.diseno.prenda.label, style: tt.titleLarge, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            _EstadoChip(estado: pedido.estado),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Taller: ${pedido.cotizacion.taller.nombre}', style: tt.bodyMedium),
                        Text(
                          '${pedido.cotizacion.taller.ciudad} · ${pedido.cotizacion.taller.plazoDias} días hábiles',
                          style: tt.bodySmall?.copyWith(color: SoraColors.disabled),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${pedido.totalUnidades} prendas', style: tt.bodyMedium),
                            Text(
                              'S/.${pedido.cotizacion.total.toStringAsFixed(2)}',
                              style: tt.titleLarge?.copyWith(color: SoraColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Toca para ver detalles ➔',
                            style: TextStyle(fontSize: 11, color: SoraColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDetallePedido(BuildContext context, Pedido pedido) {
    final diseno = pedido.diseno;
    final taller = pedido.cotizacion.taller;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SoraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SoraColors.disabled.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(diseno.prenda.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Pedido: ${pedido.id}', style: const TextStyle(fontSize: 12, color: SoraColors.disabled)),
                    ],
                  ),
                ),
                _EstadoChip(estado: pedido.estado),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Desglose de tallas
            const Text('Desglose por Tallas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SoraColors.background.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ...pedido.items.map(
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Talla ${i.talla.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${i.cantidad} unidades'),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${pedido.totalUnidades} prendas (S/.${pedido.cotizacion.total.toStringAsFixed(2)})',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: SoraColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Especificaciones de la prenda
            const Text('Detalles de Diseño', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text('• Tela: ${diseno.tela.label} (${diseno.tela.precioLabel})'),
            Text('• Técnica de confección: ${diseno.tecnicaLogo.name.toUpperCase()}'),
            if (diseno.textoLogo.isNotEmpty) Text('• Texto de estampado: "${diseno.textoLogo}"'),
            if (pedido.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Notas enviadas: ${pedido.notas}', style: const TextStyle(fontSize: 12)),
              ),
            ],
            if (diseno.logoBytes != null) ...[
              const SizedBox(height: 12),
              const Text('Logo cargado:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(diseno.logoBytes!, width: 70, height: 70, fit: BoxFit.contain),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),

            // Información del Taller asignado
            const Text('Taller Asignado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(taller.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('📍 ${taller.direccion}, ${taller.ciudad}', style: const TextStyle(fontSize: 12, color: SoraColors.disabled)),
            Text('📞 ${taller.telefono}', style: const TextStyle(fontSize: 12, color: SoraColors.disabled)),
            const SizedBox(height: 24),

            // Opción de Calificar Taller (cuando el pedido está listo o entregado)
            if (pedido.estado == EstadoPedido.listo || pedido.estado == EstadoPedido.entregado) ...[
              if (!pedido.calificado) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.star, color: Colors.white),
                    label: const Text('Calificar Trabajo del Taller', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _mostrarDialogoCalificacion(context, pedido);
                    },
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 8),
                      Text(
                        '¡Ya calificaste este taller! Gracias por tu opinión.',
                        style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],

            // Opción de cancelar (solo si está pendiente de aprobación)
            if (pedido.estado == EstadoPedido.cotizado) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SoraColors.error,
                    side: const BorderSide(color: SoraColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar esta Solicitud'),
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: SoraColors.surface,
                        title: const Text('¿Cancelar solicitud?'),
                        content: const Text('El taller no recibirá este pedido.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: SoraColors.error),
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Sí, Cancelar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmar == true && context.mounted) {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(ctx);
                      PedidosRepository.instance.actualizarEstado(pedido.id, EstadoPedido.rechazado);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Solicitud cancelada')),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoCalificacion(BuildContext context, Pedido pedido) {
    int estrellasSeleccionadas = 5;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setStateDlg) => AlertDialog(
          backgroundColor: SoraColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calificar a ${pedido.cotizacion.taller.nombre}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Cómo calificarías la calidad de confección, acabado y atención de este taller?',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final estrella = index + 1;
                  return IconButton(
                    iconSize: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    icon: Icon(
                      estrella <= estrellasSeleccionadas ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF59E0B),
                    ),
                    onPressed: () {
                      setStateDlg(() => estrellasSeleccionadas = estrella);
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                '$estrellasSeleccionadas de 5 estrellas',
                style: const TextStyle(fontWeight: FontWeight.bold, color: SoraColors.primary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: SoraColors.primary),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final tallerNombre = pedido.cotizacion.taller.nombre;
                final puntuacion = estrellasSeleccionadas;
                Navigator.pop(dlgCtx);

                await PedidosRepository.instance.calificarPedido(
                  pedidoId: pedido.id,
                  tallerId: pedido.cotizacion.taller.id,
                  puntuacion: puntuacion.toDouble(),
                );

                messenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¡Gracias! Has calificado a $tallerNombre con $puntuacion estrellas.',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: SoraColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Enviar Calificación'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final EstadoPedido estado;
  const _EstadoChip({required this.estado});

  Color _colorPorEstado() {
    switch (estado) {
      case EstadoPedido.cotizado:
        return const Color(0xFFF59E0B);
      case EstadoPedido.confirmado:
        return SoraColors.primary;
      case EstadoPedido.enProduccion:
        return const Color(0xFF8B5CF6);
      case EstadoPedido.listo:
        return const Color(0xFF10B981);
      case EstadoPedido.entregado:
        return const Color(0xFF64748B);
      case EstadoPedido.rechazado:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _colorPorEstado(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
