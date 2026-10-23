import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Paso 2: Paleta de colores
class Paso2Colores extends StatefulWidget {
  const Paso2Colores({super.key});

  @override
  State<Paso2Colores> createState() => _Paso2ColoresState();
}

class _Paso2ColoresState extends State<Paso2Colores> {
  int _tabActiva = 0;

  List<String> _tabsPara(TipoPrenda prenda) {
    switch (prenda.categoria) {
      case CategoriaPrenda.inferior:
        return const ['Principal', 'Acento', 'Bastas', 'Pretina'];
      case CategoriaPrenda.vestido:
        return const ['Principal', 'Cinturón', 'Mangas', 'Escote'];
      case CategoriaPrenda.superior:
      case CategoriaPrenda.uniforme:
        return const ['Principal', 'Acento', 'Mangas', 'Cuello'];
    }
  }

  static const List<Color> _paleta = [
    Color(0xFF1A3A5C),
    Color(0xFF2B1C14),
    Color(0xFF1B4332),
    Color(0xFF4A0E2A),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFFB04F36),
    Color(0xFFD4845A),
    Color(0xFFF6C324),
    Color(0xFF80CBC4),
    Color(0xFFEEEEEE),
    Color(0xFF212121),
    Color(0xFFE53935),
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFF7B1FA2),
  ];

  Color _colorActual(DisenoPersonalizado d) {
    switch (_tabActiva) {
      case 0: return d.colorPrincipal;
      case 1: return d.colorAccento;
      case 2: return d.colorMangas;
      case 3: return d.colorCuello;
      default: return d.colorPrincipal;
    }
  }

  Color _colorPorTab(DisenoPersonalizado d, int tab) {
    switch (tab) {
      case 0: return d.colorPrincipal;
      case 1: return d.colorAccento;
      case 2: return d.colorMangas;
      case 3: return d.colorCuello;
      default: return d.colorPrincipal;
    }
  }

  DisenoPersonalizado _aplicarColor(DisenoPersonalizado d, Color c) {
    switch (_tabActiva) {
      case 0: return d.copyWith(colorPrincipal: c);
      case 1: return d.copyWith(colorAccento: c);
      case 2: return d.copyWith(colorMangas: c);
      case 3: return d.copyWith(colorCuello: c);
      default: return d;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final diseno = provider.diseno;
    final tabs = _tabsPara(diseno.prenda);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final activo = i == _tabActiva;
                return GestureDetector(
                  onTap: () => setState(() => _tabActiva = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: activo ? SoraColors.primary : SoraColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: activo ? SoraColors.primary : SoraColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _colorPorTab(diseno, i),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tabs[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: activo ? Colors.white : SoraColors.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Text('Color para: ${tabs[_tabActiva.clamp(0, tabs.length - 1)]}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _paleta.length,
            itemBuilder: (context, index) {
              final color = _paleta[index];
              final seleccionado = _colorActual(diseno).toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () {
                  context.read<DisenadorProvider>().actualizarDiseno(
                        _aplicarColor(diseno, color),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: seleccionado ? SoraColors.primary : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: seleccionado
                        ? [BoxShadow(color: SoraColors.primary.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)]
                        : [],
                  ),
                  child: seleccionado ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
