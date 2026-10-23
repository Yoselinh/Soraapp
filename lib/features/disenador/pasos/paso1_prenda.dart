import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';
import 'package:sora_app/features/disenador/widgets/preview_prenda.dart';

/// Paso 1: Elegir prenda
class Paso1Prenda extends StatefulWidget {
  const Paso1Prenda({super.key});

  @override
  State<Paso1Prenda> createState() => _Paso1PrendaState();
}

class _Paso1PrendaState extends State<Paso1Prenda> {
  CategoriaPrenda? _filtroCategoria;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final seleccionada = provider.diseno.prenda;
    final taller = provider.tallerPreseleccionado;
    final basePrendas = taller != null
        ? TipoPrenda.values.where((p) => taller.confecciona(p)).toList()
        : TipoPrenda.values;

    final prendasFiltradas = _filtroCategoria == null
        ? basePrendas
        : basePrendas.where((p) => p.categoria == _filtroCategoria).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: PreviewPrenda(diseno: provider.diseno),
            ),
          ),
          const SizedBox(height: 20),
          Text('Selecciona el tipo de prenda', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),

          // Filtro por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoriaChip(
                  label: 'Todas',
                  activo: _filtroCategoria == null,
                  onTap: () => setState(() => _filtroCategoria = null),
                ),
                ...CategoriaPrenda.values.map((cat) => _CategoriaChip(
                      label: cat.label,
                      activo: _filtroCategoria == cat,
                      onTap: () => setState(() => _filtroCategoria = cat),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: prendasFiltradas.map((tipo) {
              final activo = tipo == seleccionada;
              return _PrendaOption(
                tipo: tipo,
                activo: activo,
                onTap: () => context.read<DisenadorProvider>().actualizarDiseno(
                      provider.diseno.copyWith(prenda: tipo),
                    ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _CategoriaChip({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? SoraColors.primary : SoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activo ? SoraColors.primary : SoraColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: activo ? Colors.white : SoraColors.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrendaOption extends StatelessWidget {
  final TipoPrenda tipo;
  final bool activo;
  final VoidCallback onTap;

  const _PrendaOption({required this.tipo, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: activo ? SoraColors.primary.withValues(alpha: 0.12) : SoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: activo ? SoraColors.primary : SoraColors.cardBorder,
            width: activo ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tipo.icono, size: 26, color: activo ? SoraColors.primary : SoraColors.onBackground),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: activo
                        ? SoraColors.primary.withValues(alpha: 0.15)
                        : SoraColors.cardBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tipo.categoria.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: activo ? SoraColors.primary : const Color(0xFF8D7060),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tipo.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: activo ? SoraColors.primary : SoraColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tipo.descripcion,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
