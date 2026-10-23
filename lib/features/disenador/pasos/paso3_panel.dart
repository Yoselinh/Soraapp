import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Paso 3: Cortes y diseño adaptados al tipo de prenda
class Paso3Panel extends StatelessWidget {
  const Paso3Panel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final diseno = provider.diseno;

    switch (diseno.prenda.categoria) {
      case CategoriaPrenda.vestido:
        return _buildOpcionesVestido(context, provider, diseno);
      case CategoriaPrenda.inferior:
        return _buildOpcionesInferior(context, provider, diseno);
      case CategoriaPrenda.superior:
      case CategoriaPrenda.uniforme:
        return _buildOpcionesSuperior(context, provider, diseno);
    }
  }

  // -------------------------------------------------------------
  // VESTIDO: LARGO, ESCOTE Y MANGAS
  // -------------------------------------------------------------
  Widget _buildOpcionesVestido(BuildContext context, DisenadorProvider provider, DisenoPersonalizado diseno) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza el corte, escote y silueta de tu vestido',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D4038)),
          ),
          const SizedBox(height: 18),

          _SeccionTitulo(titulo: 'Largo del vestido'),
          const SizedBox(height: 8),
          ...LargoPrenda.values.map((largo) {
            final activo = diseno.largo == largo;
            return _OpcionCard(
              icono: largo.icono,
              titulo: largo.label,
              subtitulo: largo.descripcion,
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(largo: largo)),
            );
          }),

          const SizedBox(height: 20),
          _SeccionTitulo(titulo: 'Tipo de escote'),
          const SizedBox(height: 8),
          ...TipoEscote.values.map((escote) {
            final activo = diseno.tipoEscote == escote;
            return _OpcionCard(
              icono: escote.icono,
              titulo: escote.label,
              subtitulo: escote.descripcion,
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(tipoEscote: escote)),
            );
          }),

          const SizedBox(height: 20),
          _SeccionTitulo(titulo: 'Tipo de manga'),
          const SizedBox(height: 8),
          ...TipoManga.values.map((manga) {
            final activo = diseno.tipoManga == manga;
            return _OpcionCard(
              icono: manga.icono,
              titulo: manga.label,
              subtitulo: manga.descripcion,
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(tipoManga: manga)),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // INFERIOR (PANTALÓN / SHORT / FALDA): LARGO Y CINTURA
  // -------------------------------------------------------------
  Widget _buildOpcionesInferior(BuildContext context, DisenadorProvider provider, DisenoPersonalizado diseno) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajusta el largo y el tipo de pretina o cintura',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D4038)),
          ),
          const SizedBox(height: 18),

          _SeccionTitulo(titulo: 'Largo de la prenda'),
          const SizedBox(height: 8),
          ...LargoPrenda.values.map((largo) {
            final activo = diseno.largo == largo;
            return _OpcionCard(
              icono: largo.icono,
              titulo: largo.label,
              subtitulo: largo.descripcion,
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(largo: largo)),
            );
          }),

          const SizedBox(height: 20),
          _SeccionTitulo(titulo: 'Tipo de cintura / Pretina'),
          const SizedBox(height: 8),
          ...TipoCintura.values.map((cintura) {
            final activo = diseno.tipoCintura == cintura;
            return _OpcionCard(
              icono: cintura.icono,
              titulo: cintura.label,
              subtitulo: cintura.descripcion,
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(tipoCintura: cintura)),
            );
          }),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SUPERIOR Y UNIFORME: PANELES Y CORTES
  // -------------------------------------------------------------
  Widget _buildOpcionesSuperior(BuildContext context, DisenadorProvider provider, DisenoPersonalizado diseno) {
    final panelActual = diseno.panel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige cómo distribuir los colores y cortes en la prenda',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D4038)),
          ),
          const SizedBox(height: 18),
          _SeccionTitulo(titulo: 'Cortes y paneles'),
          const SizedBox(height: 8),
          ...TipoPanel.values.map((panel) {
            final activo = panel == panelActual;
            return _OpcionCard(
              icono: panel.icono,
              titulo: panel.label,
              subtitulo: _descripcionPanel(panel),
              activo: activo,
              onTap: () => provider.actualizarDiseno(diseno.copyWith(panel: panel)),
            );
          }),
        ],
      ),
    );
  }

  String _descripcionPanel(TipoPanel panel) {
    switch (panel) {
      case TipoPanel.liso:
        return 'Un solo color para todo el cuerpo de la prenda';
      case TipoPanel.dividido:
        return 'Mitad izquierda y derecha de diferente color';
      case TipoPanel.diagonal:
        return 'Corte diagonal frontal con color de acento';
      case TipoPanel.rayas:
        return 'Franjas verticales con color de acento';
    }
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: SoraColors.onBackground,
      ),
    );
  }
}

class _OpcionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool activo;
  final VoidCallback onTap;

  const _OpcionCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: activo
                    ? SoraColors.primary.withValues(alpha: 0.15)
                    : SoraColors.cardBorder.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icono,
                color: activo ? SoraColors.primary : const Color(0xFF8D7060),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: activo ? SoraColors.primary : SoraColors.onBackground,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8D7060)),
                  ),
                ],
              ),
            ),
            if (activo) const Icon(Icons.check_circle, color: SoraColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}
