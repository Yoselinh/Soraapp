import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/routes/sora_router.dart';

/// Shell principal con BottomNavigationBar SORA
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(SoraRoutes.disenador)) return 1;
    if (location.startsWith(SoraRoutes.talleres)) return 2;
    if (location.startsWith(SoraRoutes.pedidos)) return 3;
    if (location.startsWith(SoraRoutes.perfil)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(SoraRoutes.home);
      case 1:
        context.go(SoraRoutes.disenador);
      case 2:
        context.go(SoraRoutes.talleres);
      case 3:
        context.go(SoraRoutes.pedidos);
      case 4:
        context.go(SoraRoutes.perfil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 16,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => _onTap(context, i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit),
              label: 'Diseñar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Talleres',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
