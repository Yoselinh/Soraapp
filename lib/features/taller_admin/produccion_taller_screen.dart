import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Pantalla de Gestión de Producción para el Taller
class ProduccionTallerScreen extends StatefulWidget {
  const ProduccionTallerScreen({super.key});

  @override
  State<ProduccionTallerScreen> createState() => _ProduccionTallerScreenState();
}

class _ProduccionTallerScreenState extends State<ProduccionTallerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final repo = context.watch<PedidosRepository>();
    final taller = auth.tallerActivo;

    final enProduccion = repo.enProduccionPorTaller(taller.id);
    final listos = repo.listosPorTaller(taller.id);
    final entregados = repo.completadosPorTaller(taller.id);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelPadding: const EdgeInsets.symmetric(horizontal: 14),
            indicatorColor: SoraColors.primary,
            labelColor: SoraColors.primary,
            unselectedLabelColor: SoraColors.disabled,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('En Confección'),
                    if (enProduccion.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _BadgeCount(count: enProduccion.length, color: const Color(0xFF8B5CF6)),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Listos'),
                    if (listos.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _BadgeCount(count: listos.length, color: const Color(0xFF10B981)),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Entregados'),
                    if (entregados.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _BadgeCount(count: entregados.length, color: const Color(0xFF64748B)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ListaPedidos(
            pedidos: enProduccion,
            mensajeVacio: 'No hay pedidos actualmente en corte o confección.',
            tipo: _TipoLista.produccion,
          ),
          _ListaPedidos(
            pedidos: listos,
            mensajeVacio: 'No hay pedidos esperando recojo o entrega.',
            tipo: _TipoLista.listo,
          ),
          _ListaPedidos(
            pedidos: entregados,
            mensajeVacio: 'Aún no tienes pedidos finalizados en el historial.',
            tipo: _TipoLista.entregado,
          ),
        ],
      ),
    );
  }
}

enum _TipoLista { produccion, listo, entregado }

class _BadgeCount extends StatelessWidget {
  final int count;
  final Color color;

  const _BadgeCount({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ListaPedidos extends StatelessWidget {
  final List<Pedido> pedidos;
  final String mensajeVacio;
  final _TipoLista tipo;

  const _ListaPedidos({
    required this.pedidos,
    required this.mensajeVacio,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (pedidos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tipo == _TipoLista.produccion
                    ? Icons.precision_manufacturing_outlined
                    : (tipo == _TipoLista.listo ? Icons.check_circle_outline : Icons.history),
                size: 56,
                color: SoraColors.disabled.withAlpha(100),
              ),
              const SizedBox(height: 16),
              Text(
                mensajeVacio,
                style: tt.bodyMedium?.copyWith(color: SoraColors.disabled),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return _PedidoProduccionCard(pedido: pedido, tipo: tipo);
      },
    );
  }
}

class _PedidoProduccionCard extends StatelessWidget {
  final Pedido pedido;
  final _TipoLista tipo;

  const _PedidoProduccionCard({required this.pedido, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final diseno = pedido.diseno;
    final repo = context.read<PedidosRepository>();

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: ID y Estado
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: SoraColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(diseno.prenda.icono, color: SoraColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pedido.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${pedido.totalUnidades} prendas · ${pedido.clienteNombre}',
                              style: const TextStyle(fontSize: 11, color: SoraColors.disabled),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ChipEstadoProduccion(estado: pedido.estado),
              ],
            ),
            const SizedBox(height: 12),

            // Prenda y detalles
            Text(diseno.prenda.label, style: tt.titleMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: diseno.colorPrincipal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 0.8),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Técnica: ${diseno.tecnicaLogo.name.toUpperCase()}',
                  style: tt.bodySmall?.copyWith(color: SoraColors.disabled),
                ),
                if (diseno.textoLogo.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text('("${diseno.textoLogo}")', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ],
              ],
            ),

            if (diseno.logoBytes != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(diseno.logoBytes!, width: 44, height: 44, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Logo adjunto (${diseno.posicionLogo.label} · ${diseno.tamanoLogo.label})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],

            if (pedido.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Nota del cliente: "${pedido.notas}"',
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.deepOrange),
              ),
            ],

            const SizedBox(height: 12),
            // Resumen de tallas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: SoraColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tallas: ${pedido.items.map((i) => '${i.talla.name.toUpperCase()}: ${i.cantidad}').join('  |  ')}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'S/. ${pedido.cotizacion.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: SoraColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Botón de avance de fase
            if (tipo == _TipoLista.produccion) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Prendas Listas para Entrega'),
                  onPressed: () {
                    repo.actualizarEstado(pedido.id, EstadoPedido.listo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Pedido ${pedido.id} marcado como listo para entrega!')),
                    );
                  },
                ),
              ),
            ] else if (tipo == _TipoLista.listo) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: SoraColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Confirmar Entrega al Cliente'),
                  onPressed: () {
                    repo.actualizarEstado(pedido.id, EstadoPedido.entregado);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('¡Pedido ${pedido.id} completado con éxito!')),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipEstadoProduccion extends StatelessWidget {
  final EstadoPedido estado;

  const _ChipEstadoProduccion({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg = Colors.white;

    switch (estado) {
      case EstadoPedido.confirmado:
        bg = SoraColors.primary;
        break;
      case EstadoPedido.enProduccion:
        bg = const Color(0xFF8B5CF6);
        break;
      case EstadoPedido.listo:
        bg = const Color(0xFF10B981);
        break;
      case EstadoPedido.entregado:
        bg = const Color(0xFF64748B);
        break;
      default:
        bg = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        estado.label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
