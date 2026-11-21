import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Pantalla de Solicitudes y Cotizaciones Entrantes para el Taller
class SolicitudesTallerScreen extends StatelessWidget {
  const SolicitudesTallerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();
    final repo = context.watch<PedidosRepository>();
    final taller = auth.tallerActivo;

    final solicitudes = repo.solicitudesPendientesPorTaller(taller.id);

    if (solicitudes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: SoraColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inbox, size: 64, color: SoraColors.disabled),
              ),
              const SizedBox(height: 20),
              Text(
                'No tienes cotizaciones pendientes',
                style: tt.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Cuando los clientes diseñen prendas y elijan a ${taller.nombre}, sus solicitudes con su información de contacto aparecerán aquí.',
                style: tt.bodyMedium?.copyWith(color: SoraColors.disabled),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Banner informativo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFFD97706), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tienes ${solicitudes.length} ${solicitudes.length == 1 ? 'cotización pendiente' : 'cotizaciones pendientes'} por revisar.',
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Lista de tarjetas de solicitudes
        ...solicitudes.map((pedido) => _SolicitudCard(pedido: pedido)),
      ],
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final Pedido pedido;

  const _SolicitudCard({required this.pedido});

  void _verDetalleCompleto(BuildContext context) {
    final diseno = pedido.diseno;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SoraColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cabecera Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Ficha de Cotización', style: tt.titleLarge),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pendiente',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Código: ${pedido.id}', style: tt.bodySmall?.copyWith(color: SoraColors.disabled)),
              const Divider(height: 24),

              // Datos del Cliente (¿De quién es?)
              Text('Datos del Solicitante', style: tt.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SoraColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SoraColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: SoraColors.primary,
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pedido.clienteNombre,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                pedido.clienteEmail,
                                style: const TextStyle(fontSize: 12, color: SoraColors.disabled),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (pedido.notas.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_note, size: 18, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Nota del cliente: "${pedido.notas}"',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),
              // Prenda y tela
              Text('Especificaciones de Prenda', style: tt.titleMedium),
              const SizedBox(height: 8),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(diseno.prenda.icono, color: SoraColors.primary, size: 28),
                title: Text(diseno.prenda.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('Tela: ${diseno.tela.label} · Corte: ${diseno.largo.label}'),
                trailing: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: diseno.colorPrincipal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // Distribución de Tallas
              Text('Desglose de Tallas', style: tt.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SoraColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SoraColors.cardBorder),
                ),
                child: Column(
                  children: [
                    ...pedido.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Talla ${item.talla.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${item.cantidad} prendas', style: const TextStyle(color: SoraColors.disabled)),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de prendas:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${pedido.totalUnidades} prendas', style: const TextStyle(fontWeight: FontWeight.bold, color: SoraColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // Personalización
              Text('Técnica y Arte', style: tt.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.brush, size: 16),
                    label: Text(diseno.tecnicaLogo.name.toUpperCase()),
                  ),
                  if (diseno.textoLogo.isNotEmpty)
                    Chip(
                      avatar: const Icon(Icons.title, size: 16),
                      label: Text('Texto: "${diseno.textoLogo}"'),
                    ),
                ],
              ),

              if (diseno.logoBytes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SoraColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SoraColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          diseno.logoBytes!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Arte / Logo del Cliente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Posición: ${diseno.posicionLogo.label} · ${diseno.tamanoLogo.label}', style: const TextStyle(fontSize: 11, color: SoraColors.disabled)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SoraColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Precio Cotizado Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      'S/. ${pedido.cotizacion.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: SoraColors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Botones de acción dentro del modal
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SoraColors.error,
                        side: const BorderSide(color: SoraColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        context.read<PedidosRepository>().rechazarPedido(pedido.id);
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Cotización rechazada')),
                        );
                      },
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: SoraColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final messenger = ScaffoldMessenger.of(context);
                        context.read<PedidosRepository>().actualizarEstado(pedido.id, EstadoPedido.enProduccion);
                        Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('¡Cotización ${pedido.id} aceptada y enviada a Producción!'),
                            action: SnackBarAction(
                              label: 'Ver Producción',
                              textColor: Colors.white,
                              onPressed: () => context.go('/taller/produccion'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Aceptar Cotización'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diseno = pedido.diseno;

    // Resumen de tallas en texto corto (ej: "M: 12 · L: 18")
    final tallasResumen = pedido.items
        .where((i) => i.cantidad > 0)
        .map((i) => '${i.talla.name}: ${i.cantidad}')
        .join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: SoraColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila 1: ID de Pedido, Fecha y Chip Estado ────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: SoraColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(diseno.prenda.icono, color: SoraColors.primary, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pedido.id,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${pedido.fechaCreacion.day}/${pedido.fechaCreacion.month}/${pedido.fechaCreacion.year}',
                              style: const TextStyle(fontSize: 11, color: SoraColors.disabled),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'Cotización Solicitada',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Fila 2: ¿DE QUIÉN ES? (Información del Cliente) ──────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: SoraColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: SoraColors.cardBorder.withAlpha(120)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: SoraColors.primary,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pedido.clienteNombre,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          pedido.clienteEmail,
                          style: const TextStyle(fontSize: 11, color: SoraColors.disabled),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Nota del cliente si la hay
            if (pedido.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withAlpha(150),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Instrucción: ${pedido.notas}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Fila 3: ¿CUÁL ES LA PRENDA Y ESPECIFICACIONES? ─────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: diseno.colorPrincipal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400, width: 0.8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${diseno.prenda.label} · ${diseno.tela.label}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Técnica: ${diseno.tecnicaLogo.name.toUpperCase()}${diseno.textoLogo.isNotEmpty ? ' ("${diseno.textoLogo}")' : ''}',
                        style: const TextStyle(fontSize: 12, color: SoraColors.disabled),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tallasResumen.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Tallas: $tallasResumen',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (diseno.logoBytes != null) ...[
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      diseno.logoBytes!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Fila 4: Total y Cantidad ──────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Volumen', style: TextStyle(fontSize: 11, color: SoraColors.disabled)),
                    Text(
                      '${pedido.totalUnidades} prendas',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Monto Total Cotizado', style: TextStyle(fontSize: 11, color: SoraColors.disabled)),
                    Text(
                      'S/. ${pedido.cotizacion.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: SoraColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Fila 5: Botones de Acción directos ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _verDetalleCompleto(context),
                    child: const Text('Ficha Técnica', overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Rechazar Cotización',
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: SoraColors.surface,
                        title: const Text('¿Rechazar cotización?'),
                        content: Text('¿Deseas rechazar el pedido ${pedido.id} de ${pedido.clienteNombre}?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Volver')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: SoraColors.error),
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Rechazar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true && context.mounted) {
                      context.read<PedidosRepository>().rechazarPedido(pedido.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cotización rechazada')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: SoraColors.primary,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      'Aceptar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () {
                      context.read<PedidosRepository>().actualizarEstado(pedido.id, EstadoPedido.enProduccion);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Pedido ${pedido.id} aceptado y en confección!'),
                          action: SnackBarAction(
                            label: 'Ver Producción',
                            textColor: Colors.white,
                            onPressed: () => context.go('/taller/produccion'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
