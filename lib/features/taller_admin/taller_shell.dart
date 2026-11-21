import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/data/pedidos_repository.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Shell de navegación exclusivo para el Modo Taller
class TallerShell extends StatelessWidget {
  final Widget child;

  const TallerShell({super.key, required this.child});

  static const _rutas = [
    '/taller/solicitudes',
    '/taller/produccion',
    '/taller/tarifario',
    '/taller/perfil',
  ];

  int _calcularIndice(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _rutas.length; i++) {
      if (location.startsWith(_rutas[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Protección de ruta: Si no es taller, no tiene acceso a esta sección
    if (!auth.esTaller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        context.go('/');
        messenger?.showSnackBar(
          const SnackBar(
            content: Text('Acceso restringido: Esta sección es exclusiva para talleres de confección.'),
            backgroundColor: SoraColors.error,
          ),
        );
      });
      return const Scaffold(
        backgroundColor: SoraColors.background,
        body: Center(child: CircularProgressIndicator(color: SoraColors.primary)),
      );
    }

    final indiceActual = _calcularIndice(context);
    final taller = auth.tallerActivo;
    final repo = context.watch<PedidosRepository>();

    final numSolicitudes = repo.solicitudesPendientesPorTaller(taller.id).length;
    final numProduccion = repo.enProduccionPorTaller(taller.id).length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, size: 18, color: SoraColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    taller.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              '${taller.ciudad} · Modo Taller',
              style: const TextStyle(fontSize: 11, color: SoraColors.disabled),
            ),
          ],
        ),
        actions: [
          // Botón para alternar rápidamente a Modo Cliente
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.person_outline, size: 16, color: Colors.white),
              label: const Text(
                'Ver como Cliente',
                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: SoraColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                auth.cambiarRol(RolUsuario.cliente);
                context.go('/');
              },
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceActual,
        onDestinationSelected: (idx) {
          if (idx != indiceActual) {
            context.go(_rutas[idx]);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: numSolicitudes > 0,
              label: Text('$numSolicitudes'),
              child: const Icon(Icons.inbox_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: numSolicitudes > 0,
              label: Text('$numSolicitudes'),
              child: const Icon(Icons.inbox),
            ),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: numProduccion > 0,
              label: Text('$numProduccion'),
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.precision_manufacturing_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: numProduccion > 0,
              label: Text('$numProduccion'),
              backgroundColor: const Color(0xFF8B5CF6),
              child: const Icon(Icons.precision_manufacturing),
            ),
            label: 'Producción',
          ),
          const NavigationDestination(
            icon: Icon(Icons.price_change_outlined),
            selectedIcon: Icon(Icons.price_change),
            label: 'Tarifario',
          ),
          const NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Mi Taller',
          ),
        ],
      ),
    );
  }
}
