import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Paso 6: Detalles adicionales
class Paso6Detalles extends StatelessWidget {
  const Paso6Detalles({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final diseno = provider.diseno;

    void update(DisenoPersonalizado d) => context.read<DisenadorProvider>().actualizarDiseno(d);

    final cat = diseno.prenda.categoria;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Seccion(
            titulo: cat == CategoriaPrenda.vestido
                ? 'Cierres y cremalleras'
                : (cat == CategoriaPrenda.inferior ? 'Cierre de pretina' : 'Cierres'),
            children: [
              _DetalleToggle(
                label: cat == CategoriaPrenda.vestido
                    ? 'Cierre invisible posterior'
                    : (cat == CategoriaPrenda.inferior ? 'Cierre metálico frontal' : 'Cierre metálico'),
                descripcion: cat == CategoriaPrenda.vestido
                    ? 'Cierre discreto y elegante en la espalda'
                    : 'Resistente y duradero',
                precioExtra: '+S/.5',
                valor: diseno.tieneCierreMetal,
                onChanged: (v) => update(diseno.copyWith(tieneCierreMetal: v)),
              ),
              _DetalleToggle(
                label: cat == CategoriaPrenda.vestido ? 'Cierre lateral ligero' : 'Cierre plástico / estándar',
                descripcion: 'Ligero y económico',
                precioExtra: '+S/.2',
                valor: diseno.tieneCierrePlastico,
                onChanged: (v) => update(diseno.copyWith(tieneCierrePlastico: v)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Seccion(
            titulo: cat == CategoriaPrenda.vestido ? 'Bolsillos y forro' : 'Bolsillos',
            children: [
              _DetalleToggle(
                label: cat == CategoriaPrenda.vestido
                    ? 'Bolsillos laterales ocultos'
                    : 'Bolsillos laterales',
                descripcion: 'A los costados de la prenda',
                precioExtra: '+S/.3',
                valor: diseno.tieneBolsilloLateral,
                onChanged: (v) => update(diseno.copyWith(tieneBolsilloLateral: v)),
              ),
              if (cat != CategoriaPrenda.vestido)
                _DetalleToggle(
                  label: cat == CategoriaPrenda.inferior ? 'Bolsillo posterior' : 'Bolsillo pecho',
                  descripcion: cat == CategoriaPrenda.inferior
                      ? 'En la parte trasera'
                      : 'En la parte delantera superior',
                  precioExtra: '+S/.2.5',
                  valor: diseno.tieneBolsilloPecho,
                  onChanged: (v) => update(diseno.copyWith(tieneBolsilloPecho: v)),
                ),
              _DetalleToggle(
                label: cat == CategoriaPrenda.vestido
                    ? 'Forro interior suave'
                    : 'Bolsillo interno de seguridad',
                descripcion: cat == CategoriaPrenda.vestido
                    ? 'Mayor confort y caída elegante'
                    : 'Oculto en el interior',
                precioExtra: '+S/.4',
                valor: diseno.tieneBolsilloInterno,
                onChanged: (v) => update(diseno.copyWith(tieneBolsilloInterno: v)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SoraColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: SoraColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_outlined, color: SoraColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Extras acumulados', style: TextStyle(fontWeight: FontWeight.w700, color: SoraColors.primary, fontSize: 13)),
                      Text('Los extras se suman al precio por prenda en cada taller.', style: TextStyle(fontSize: 11, color: Color(0xFF5D4038))),
                    ],
                  ),
                ),
                Text(
                  '+S/.${diseno.costoExtrasDiseno.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: SoraColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> children;

  const _Seccion({required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _DetalleToggle extends StatelessWidget {
  final String label;
  final String descripcion;
  final String precioExtra;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _DetalleToggle({
    required this.label,
    required this.descripcion,
    required this.precioExtra,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: valor ? SoraColors.primary.withValues(alpha: 0.08) : SoraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: valor ? SoraColors.primary.withValues(alpha: 0.4) : SoraColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: valor ? SoraColors.primary : SoraColors.onBackground,
                  ),
                ),
                Text(descripcion, style: const TextStyle(fontSize: 11, color: Color(0xFF8D7060))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: valor ? SoraColors.primary.withValues(alpha: 0.15) : SoraColors.cardBorder.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              precioExtra,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: valor ? SoraColors.primary : const Color(0xFF8D7060),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeThumbColor: SoraColors.primary,
          ),
        ],
      ),
    );
  }
}
