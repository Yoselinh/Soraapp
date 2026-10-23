import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/core/routes/sora_router.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/features/disenador/widgets/preview_prenda.dart';

/// Pantalla de resumen del diseño completado
class DisenoListoScreen extends StatelessWidget {
  const DisenoListoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DisenadorProvider>();
    final diseno = provider.diseno;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: SoraColors.background,
      appBar: AppBar(
        backgroundColor: SoraColors.background,
        title: const Text('Tu diseño está listo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [SoraColors.primary.withValues(alpha: 0.15), SoraColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('¡Tu diseño está listo!', style: tt.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Disfruta algo increíble. Ahora es momento de solicitarlo.',
                    style: tt.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: PreviewPrenda(diseno: diseno),
                  ),
                  const SizedBox(height: 24),
                  Text('Detalles del diseño', style: tt.headlineSmall),
                  const SizedBox(height: 12),
                  if (provider.tieneTallerPreseleccionado) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: SoraColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SoraColors.primary.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront, color: SoraColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Taller preseleccionado',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF8D7060)),
                                ),
                                Text(
                                  '${provider.tallerPreseleccionado!.nombre} · ${provider.tallerPreseleccionado!.ciudad}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SoraColors.primary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _ResumenCard(diseno: diseno),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.push(SoraRoutes.distribucionTallas),
                    icon: const Icon(Icons.request_quote_outlined),
                    label: Text(
                      provider.tieneTallerPreseleccionado
                          ? 'Cotizar con ${provider.tallerPreseleccionado!.nombre}'
                          : 'Solicitar cotización',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.reiniciar();
                      context.go(SoraRoutes.disenador);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar diseño'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final DisenoPersonalizado diseno;
  const _ResumenCard({required this.diseno});

  @override
  Widget build(BuildContext context) {
    final cat = diseno.prenda.categoria;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoraColors.cardBorder),
      ),
      child: Column(
        children: [
          _FilaResumen(label: 'Prenda', valor: '${diseno.prenda.label} (${cat.label})'),
          _FilaResumen(label: 'Tela', valor: diseno.tela.label),
          if (cat == CategoriaPrenda.vestido) ...[
            _FilaResumen(label: 'Largo', valor: diseno.largo.label),
            _FilaResumen(label: 'Escote', valor: diseno.tipoEscote.label),
            _FilaResumen(label: 'Mangas', valor: diseno.tipoManga.label),
          ] else if (cat == CategoriaPrenda.inferior) ...[
            _FilaResumen(label: 'Largo', valor: diseno.largo.label),
            _FilaResumen(label: 'Cintura', valor: diseno.tipoCintura.label),
          ] else ...[
            _FilaResumen(label: 'Panel', valor: diseno.panel.label),
          ],
          _FilaResumen(
            label: 'Logo/Arte',
            valor: diseno.tieneLogo
                ? '${diseno.tecnicaLogo.label} (${diseno.tamanoLogo.label})'
                : (diseno.posicionesLogo.isEmpty ? 'Sin logo' : diseno.posicionesLogo.map((p) => p.label).join(', ')),
          ),
          if (diseno.tieneLogoOTexto)
            _FilaResumen(
              label: 'Ubicación',
              valor: diseno.posicionLogo.label,
            ),
          if (diseno.textoLogo.isNotEmpty) _FilaResumen(label: 'Texto', valor: '"${diseno.textoLogo}"'),
          _FilaResumen(
            label: 'Extras',
            valor: diseno.costoExtrasDiseno > 0 ? '+S/.${diseno.costoExtrasDiseno.toStringAsFixed(1)} / prenda' : 'Sin extras',
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ColorDot(color: diseno.colorPrincipal, label: 'Principal'),
              _ColorDot(color: diseno.colorAccento, label: cat == CategoriaPrenda.vestido ? 'Cinturón' : 'Acento'),
              _ColorDot(color: diseno.colorMangas, label: cat == CategoriaPrenda.inferior ? 'Bastas' : 'Mangas'),
              _ColorDot(color: diseno.colorCuello, label: cat == CategoriaPrenda.inferior ? 'Pretina' : (cat == CategoriaPrenda.vestido ? 'Escote' : 'Cuello')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  final String label;
  final String valor;
  const _FilaResumen({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF8D7060), fontWeight: FontWeight.w600))),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SoraColors.onBackground))),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: SoraColors.cardBorder, width: 1.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF8D7060))),
      ],
    );
  }
}
