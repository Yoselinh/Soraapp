import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Paso 5: Selección de tela
class Paso5Tela extends StatelessWidget {
  const Paso5Tela({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final telaActual = provider.diseno.tela;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'La tela determina la calidad, durabilidad y confort de tu prenda.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D4038)),
          ),
          const SizedBox(height: 20),
          ...TipoTela.values.map((tela) {
            final activo = tela == telaActual;
            return GestureDetector(
              onTap: () => context.read<DisenadorProvider>().actualizarDiseno(
                    provider.diseno.copyWith(tela: tela),
                  ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activo ? SoraColors.primary.withValues(alpha: 0.10) : SoraColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: activo ? SoraColors.primary : SoraColors.cardBorder,
                    width: activo ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: activo ? SoraColors.primary : SoraColors.cardBorder.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(_emojiTela(tela), style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tela.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: activo ? SoraColors.primary : SoraColors.onBackground,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: activo ? SoraColors.primary : SoraColors.cardBorder,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${tela.precioLabel}/u extra',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: activo ? Colors.white : const Color(0xFF5D4038),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tela.descripcion,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8D7060), height: 1.4),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: _tagsTela(tela).map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: SoraColors.cardBorder.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(tag, style: const TextStyle(fontSize: 10, color: Color(0xFF5D4038))),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _emojiTela(TipoTela tela) {
    switch (tela) {
      case TipoTela.taslan: return '🌧️';
      case TipoTela.polar: return '❄️';
      case TipoTela.algodon: return '☁️';
      case TipoTela.lino: return '🌿';
      case TipoTela.denim: return '👖';
      case TipoTela.gabardina: return '🛡️';
    }
  }

  List<String> _tagsTela(TipoTela tela) {
    switch (tela) {
      case TipoTela.taslan: return ['Impermeable', 'Resistente', 'Deportivo'];
      case TipoTela.polar: return ['Abrigado', 'Suave', 'Invierno'];
      case TipoTela.algodon: return ['Transpirable', 'Clásico', 'Diario'];
      case TipoTela.lino: return ['Fresco', 'Elegante', 'Natural'];
      case TipoTela.denim: return ['Resistente', 'Durable', 'Estructurado'];
      case TipoTela.gabardina: return ['Robusto', 'Institucional', 'Trabajo'];
    }
  }
}
