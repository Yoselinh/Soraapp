import 'package:flutter/material.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/data/talleres_repository.dart';
import 'package:sora_app/features/talleres/taller_detalle_screen.dart';

/// Pantalla principal de Exploración de Talleres
class TalleresScreen extends StatefulWidget {
  const TalleresScreen({super.key});

  @override
  State<TalleresScreen> createState() => _TalleresScreenState();
}

class _TalleresScreenState extends State<TalleresScreen> {
  TipoPrenda? _prendaFiltro;
  TecnicaConfeccion? _tecnicaFiltro;

  @override
  Widget build(BuildContext context) {
    final todosLosTalleres = TalleresRepository.instance.talleres;

    // Aplicar filtros por prenda y técnica
    final talleresFiltrados = todosLosTalleres.where((t) {
      final cumplePrenda = _prendaFiltro == null || t.confecciona(_prendaFiltro!);
      final cumpleTecnica = _tecnicaFiltro == null || t.tieneTecnica(_tecnicaFiltro!);
      return cumplePrenda && cumpleTecnica;
    }).toList();

    return Scaffold(
      backgroundColor: SoraColors.background,
      appBar: AppBar(
        backgroundColor: SoraColors.background,
        title: const Text('Talleres de confección'),
        actions: [
          if (_prendaFiltro != null || _tecnicaFiltro != null)
            TextButton(
              onPressed: () => setState(() {
                _prendaFiltro = null;
                _tecnicaFiltro = null;
              }),
              child: const Text('Limpiar'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección de Filtros
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            decoration: const BoxDecoration(
              color: SoraColors.background,
              border: Border(bottom: BorderSide(color: SoraColors.cardBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro por prenda
                const Text(
                  'Filtrar por prenda:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D4038)),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltroChip(
                        label: 'Todas',
                        icono: Icons.all_inclusive,
                        activo: _prendaFiltro == null,
                        onTap: () => setState(() => _prendaFiltro = null),
                      ),
                      ...TipoPrenda.values.map((prenda) => _FiltroChip(
                            label: prenda.label,
                            icono: prenda.icono,
                            activo: _prendaFiltro == prenda,
                            onTap: () => setState(() => _prendaFiltro = prenda),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Filtro por técnica
                const Text(
                  'Filtrar por técnica:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5D4038)),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FiltroChip(
                        label: 'Todas las técnicas',
                        icono: Icons.auto_awesome_outlined,
                        activo: _tecnicaFiltro == null,
                        onTap: () => setState(() => _tecnicaFiltro = null),
                      ),
                      ...TecnicaConfeccion.values.map((tec) => _FiltroChip(
                            label: tec.label,
                            icono: tec.icono,
                            activo: _tecnicaFiltro == tec,
                            onTap: () => setState(() => _tecnicaFiltro = tec),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  '${talleresFiltrados.length} ${talleresFiltrados.length == 1 ? 'taller encontrado' : 'talleres encontrados'}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8D7060)),
                ),
              ],
            ),
          ),

          // Lista de talleres
          Expanded(
            child: talleresFiltrados.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 48, color: Color(0xFF8D7060)),
                          const SizedBox(height: 12),
                          const Text(
                            'No se encontraron talleres',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Prueba combinando otros filtros de prenda y técnica.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF8D7060)),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton(
                            onPressed: () => setState(() {
                              _prendaFiltro = null;
                              _tecnicaFiltro = null;
                            }),
                            child: const Text('Mostrar todos'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: talleresFiltrados.length,
                    itemBuilder: (context, index) {
                      final taller = talleresFiltrados[index];
                      return _TallerItemCard(
                        taller: taller,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TallerDetalleScreen(taller: taller),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.icono,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? SoraColors.primary : SoraColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activo ? SoraColors.primary : SoraColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 14,
                color: activo ? Colors.white : const Color(0xFF8D7060),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: activo ? Colors.white : SoraColors.onBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TallerItemCard extends StatelessWidget {
  final Taller taller;
  final VoidCallback onTap;

  const _TallerItemCard({required this.taller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SoraColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Nombre y Calificación
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taller.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: SoraColors.onBackground),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF8D7060)),
                          Text(' ${taller.ciudad}', style: const TextStyle(fontSize: 12, color: Color(0xFF8D7060))),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule, size: 14, color: Color(0xFF8D7060)),
                          Text(' ${taller.plazoDias} días', style: const TextStyle(fontSize: 12, color: Color(0xFF8D7060))),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6C324).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFD4845A)),
                      const SizedBox(width: 4),
                      Text(
                        taller.calificacion.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: SoraColors.onBackground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Descripción breve
            Text(
              taller.descripcion,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5D4038), height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Técnicas
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                const Text('Técnicas: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8D7060))),
                ...taller.tecnicas.map((tec) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: SoraColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tec.label,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: SoraColors.primary),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 8),

            // Prendas (chips resumidos)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: taller.prendas.take(5).map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: SoraColors.cardBorder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.label,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF5D4038)),
                    ),
                  )).toList()
                ..addAll(
                  taller.prendas.length > 5
                      ? [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: SoraColors.cardBorder.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${taller.prendas.length - 5}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF5D4038), fontWeight: FontWeight.w600),
                            ),
                          )
                        ]
                      : [],
                ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Pie: Precio base y botón ver detalle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Desde S/.${taller.tablaPrecios.precioBase.toStringAsFixed(0)} / prenda',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: SoraColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ver taller',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: SoraColors.secondary),
                ),
                const Icon(Icons.arrow_forward_ios, size: 12, color: SoraColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
