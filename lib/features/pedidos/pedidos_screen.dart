import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/data/pedidos_repository.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: Consumer<PedidosRepository>(
        builder: (context, repo, _) {
          final pedidos = repo.pedidos;
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
              final confirmado = pedido.estado == EstadoPedido.confirmado;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                          _EstadoChip(confirmado: confirmado),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Taller: ${pedido.cotizacion.taller.nombre}', style: tt.bodyMedium),
                      Text(
                        '${pedido.cotizacion.taller.ciudad} · ${pedido.cotizacion.taller.plazoDias} días',
                        style: tt.bodySmall,
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final bool confirmado;
  const _EstadoChip({required this.confirmado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: confirmado ? SoraColors.primary : const Color(0xFFE8A87C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        confirmado ? 'Confirmado' : 'Cotizado',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
