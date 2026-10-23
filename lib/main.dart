import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/sora_theme.dart';
import 'core/routes/sora_router.dart';
import 'data/pedidos_repository.dart';
import 'features/disenador/disenador_provider.dart';
import 'features/cotizacion/cotizacion_provider.dart';

void main() {
  runApp(const SoraApp());
}

class SoraApp extends StatelessWidget {
  const SoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DisenadorProvider()),
        ChangeNotifierProvider(create: (_) => CotizacionProvider()),
        ChangeNotifierProvider.value(value: PedidosRepository.instance),
      ],
      child: MaterialApp.router(
        title: 'SORA',
        debugShowCheckedModeBanner: false,
        theme: SoraTheme.theme,
        routerConfig: soraRouter,
      ),
    );
  }
}
