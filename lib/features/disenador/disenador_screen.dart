import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/features/disenador/pasos/paso1_prenda.dart';
import 'package:sora_app/features/disenador/pasos/paso2_colores.dart';
import 'package:sora_app/features/disenador/pasos/paso3_panel.dart';
import 'package:sora_app/features/disenador/pasos/paso4_logos.dart';
import 'package:sora_app/features/disenador/pasos/paso5_tela.dart';
import 'package:sora_app/features/disenador/pasos/paso6_detalles.dart';
import 'package:sora_app/features/disenador/widgets/preview_prenda.dart';

class DisenadorScreen extends StatelessWidget {
  const DisenadorScreen({super.key});

  static const List<String> _titulosPasos = [
    'Elige tu prenda',
    'Dale color',
    'Cortes y diseño',
    'Logos y estampados',
    'Selecciona la tela',
    'Detalles adicionales',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DisenadorProvider>(
      builder: (context, provider, _) {
        final paso = provider.pasoActual;
        return Scaffold(
          backgroundColor: SoraColors.background,
          appBar: AppBar(
            backgroundColor: SoraColors.background,
            leading: paso > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: provider.retrocederPaso,
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASO ${paso + 1} DE ${DisenadorProvider.totalPasos}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SoraColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  _obtenerTituloPaso(paso, provider.diseno.prenda),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoraColors.onBackground,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: provider.reiniciar,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
          body: Column(
            children: [
              // Chip de taller preseleccionado
              if (provider.tieneTallerPreseleccionado)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: SoraColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SoraColors.primary.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, size: 18, color: SoraColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cotizando con: ${provider.tallerPreseleccionado!.nombre}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SoraColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: provider.limpiarTallerPreseleccionado,
                        child: const Icon(Icons.close, size: 16, color: SoraColors.primary),
                      ),
                    ],
                  ),
                ),

              // Indicador de progreso
              _PasoIndicador(
                pasoActual: paso,
                totalPasos: DisenadorProvider.totalPasos,
              ),

              // Vista previa 2D (pasos 1-4)
              if (paso > 0 && paso < 5)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    height: 180,
                    child: PreviewPrenda(diseno: provider.diseno),
                  ),
                ),

              // Contenido del paso
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _buildPaso(paso),
                ),
              ),

              // Botón siguiente
              _BotonSiguiente(paso: paso, provider: provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaso(int paso) {
    switch (paso) {
      case 0:
        return const Paso1Prenda(key: ValueKey('paso1'));
      case 1:
        return const Paso2Colores(key: ValueKey('paso2'));
      case 2:
        return const Paso3Panel(key: ValueKey('paso3'));
      case 3:
        return const Paso4Logos(key: ValueKey('paso4'));
      case 4:
        return const Paso5Tela(key: ValueKey('paso5'));
      case 5:
        return const Paso6Detalles(key: ValueKey('paso6'));
      default:
        return const SizedBox.shrink();
    }
  }
  static String _obtenerTituloPaso(int paso, TipoPrenda prenda) {
    if (paso == 2) {
      switch (prenda.categoria) {
        case CategoriaPrenda.vestido:
          return 'Largo, escote y mangas';
        case CategoriaPrenda.inferior:
          return 'Largo y cintura';
        case CategoriaPrenda.superior:
        case CategoriaPrenda.uniforme:
          return 'Cortes y diseño';
      }
    }
    return _titulosPasos[paso];
  }
}

class _PasoIndicador extends StatelessWidget {
  final int pasoActual;
  final int totalPasos;

  const _PasoIndicador({required this.pasoActual, required this.totalPasos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(totalPasos, (i) {
          final completado = i < pasoActual;
          final activo = i == pasoActual;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: (completado || activo) ? SoraColors.primary : SoraColors.cardBorder,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BotonSiguiente extends StatelessWidget {
  final int paso;
  final DisenadorProvider provider;

  const _BotonSiguiente({required this.paso, required this.provider});

  @override
  Widget build(BuildContext context) {
    final esUltimoPaso = paso == DisenadorProvider.totalPasos - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: SoraColors.background,
        border: Border(top: BorderSide(color: SoraColors.cardBorder)),
      ),
      child: FilledButton(
        onPressed: () {
          if (esUltimoPaso) {
            context.push(SoraRoutes.disenoListo);
          } else {
            provider.avanzarPaso();
          }
        },
        child: Text(
          esUltimoPaso ? 'Ver mi diseño' : 'Siguiente: ${_siguienteLabel(paso, provider.diseno.prenda)}',
        ),
      ),
    );
  }

  String _siguienteLabel(int paso, TipoPrenda prenda) {
    if (paso == 1) {
      switch (prenda.categoria) {
        case CategoriaPrenda.vestido:
          return 'Largo y escote';
        case CategoriaPrenda.inferior:
          return 'Largo y cintura';
        case CategoriaPrenda.superior:
        case CategoriaPrenda.uniforme:
          return 'Cortes y diseño';
      }
    }
    const labels = ['Colores', 'Cortes y diseño', 'Logos', 'Tela', 'Detalles', ''];
    return labels[paso];
  }
}
