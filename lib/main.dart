import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/sora_theme.dart';
import 'core/routes/sora_router.dart';
import 'data/pedidos_repository.dart';
import 'data/talleres_repository.dart';
import 'features/disenador/disenador_provider.dart';
import 'features/cotizacion/cotizacion_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SoraApp());
}

class SoraApp extends StatelessWidget {
  const SoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DisenadorProvider()),
        ChangeNotifierProvider(create: (_) => CotizacionProvider()),
        ChangeNotifierProvider.value(value: PedidosRepository.instance),
        ChangeNotifierProvider.value(value: TalleresRepository.instance),
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
