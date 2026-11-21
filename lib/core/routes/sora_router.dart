import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/features/auth/auth_screen.dart';
import 'package:sora_app/features/home/home_screen.dart';
import 'package:sora_app/features/disenador/disenador_screen.dart';
import 'package:sora_app/features/cotizacion/cotizacion_screen.dart';
import 'package:sora_app/features/cotizacion/distribucion_tallas_screen.dart';
import 'package:sora_app/features/pedidos/pedidos_screen.dart';
import 'package:sora_app/features/perfil/perfil_screen.dart';
import 'package:sora_app/features/disenador/diseno_listo_screen.dart';
import 'package:sora_app/core/shell/main_shell.dart';
import 'package:sora_app/features/talleres/talleres_screen.dart';

// Rutas de administración para el Taller
import 'package:sora_app/features/taller_admin/taller_shell.dart';
import 'package:sora_app/features/taller_admin/solicitudes_taller_screen.dart';
import 'package:sora_app/features/taller_admin/produccion_taller_screen.dart';
import 'package:sora_app/features/taller_admin/tarifario_taller_screen.dart';
import 'package:sora_app/features/taller_admin/perfil_taller_screen.dart';

/// Rutas nombradas de la app SORA
abstract class SoraRoutes {
  // Autenticación inicial
  static const auth = '/auth';

  // Rutas del Cliente
  static const home = '/';
  static const disenador = '/disenador';
  static const talleres = '/talleres';
  static const disenios = '/talleres'; // alias para compatibilidad
  static const pedidos = '/pedidos';
  static const perfil = '/perfil';
  static const distribucionTallas = '/distribucion-tallas';
  static const cotizacion = '/cotizacion';
  static const disenoListo = '/diseno-listo';

  // Rutas del Taller
  static const tallerSolicitudes = '/taller/solicitudes';
  static const tallerProduccion = '/taller/produccion';
  static const tallerTarifario = '/taller/tarifario';
  static const tallerPerfil = '/taller/perfil';
}

final GoRouter soraRouter = GoRouter(
  initialLocation: SoraRoutes.auth,
  routes: [
    // Pantalla de autenticación y selección de rol
    GoRoute(
      path: SoraRoutes.auth,
      builder: (context, state) => const AuthScreen(),
    ),

    // Shell del Cliente
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: SoraRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: SoraRoutes.disenador,
          builder: (context, state) => const DisenadorScreen(),
        ),
        GoRoute(
          path: SoraRoutes.talleres,
          builder: (context, state) => const TalleresScreen(),
        ),
        GoRoute(
          path: SoraRoutes.pedidos,
          builder: (context, state) => const PedidosScreen(),
        ),
        GoRoute(
          path: SoraRoutes.perfil,
          builder: (context, state) => const PerfilScreen(),
        ),
      ],
    ),

    // Shell del Taller
    ShellRoute(
      builder: (context, state, child) => TallerShell(child: child),
      routes: [
        GoRoute(
          path: SoraRoutes.tallerSolicitudes,
          builder: (context, state) => const SolicitudesTallerScreen(),
        ),
        GoRoute(
          path: SoraRoutes.tallerProduccion,
          builder: (context, state) => const ProduccionTallerScreen(),
        ),
        GoRoute(
          path: SoraRoutes.tallerTarifario,
          builder: (context, state) => const TarifarioTallerScreen(),
        ),
        GoRoute(
          path: SoraRoutes.tallerPerfil,
          builder: (context, state) => const PerfilTallerScreen(),
        ),
      ],
    ),

    // Pantallas sin shell (sin BottomNav)
    GoRoute(
      path: SoraRoutes.disenoListo,
      builder: (context, state) => const DisenoListoScreen(),
    ),
    GoRoute(
      path: SoraRoutes.distribucionTallas,
      builder: (context, state) => const DistribucionTallasScreen(),
    ),
    GoRoute(
      path: SoraRoutes.cotizacion,
      builder: (context, state) => const CotizacionScreen(),
    ),
  ],
);

/// Placeholder para la pestaña "Diseños"
class DiseniosPlaceholderScreen extends StatelessWidget {
  const DiseniosPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Diseños')),
      body: const Center(
        child: Text('Próximamente', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
