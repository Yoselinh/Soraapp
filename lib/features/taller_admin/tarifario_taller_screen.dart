import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/data/talleres_repository.dart';
import 'package:sora_app/providers/auth_provider.dart';

/// Pantalla donde el taller administra sus precios base, técnicas y plazos
class TarifarioTallerScreen extends StatefulWidget {
  const TarifarioTallerScreen({super.key});

  @override
  State<TarifarioTallerScreen> createState() => _TarifarioTallerScreenState();
}

class _TarifarioTallerScreenState extends State<TarifarioTallerScreen> {
  late TextEditingController _precioBaseCtrl;
  late TextEditingController _plazoDiasCtrl;
  late TextEditingController _costoBordadoCtrl;
  late TextEditingController _costoEstampadoCtrl;
  late TextEditingController _cierreMetalCtrl;

  @override
  void initState() {
    super.initState();
    final taller = context.read<AuthProvider>().tallerActivo;
    _precioBaseCtrl = TextEditingController(text: taller.tablaPrecios.precioBase.toStringAsFixed(1));
    _plazoDiasCtrl = TextEditingController(text: taller.plazoDias.toString());
    _costoBordadoCtrl = TextEditingController(text: taller.tablaPrecios.costoBordado.toStringAsFixed(1));
    _costoEstampadoCtrl = TextEditingController(text: taller.tablaPrecios.costoEstampado.toStringAsFixed(1));
    _cierreMetalCtrl = TextEditingController(text: taller.tablaPrecios.costoCierreMetal.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _precioBaseCtrl.dispose();
    _plazoDiasCtrl.dispose();
    _costoBordadoCtrl.dispose();
    _costoEstampadoCtrl.dispose();
    _cierreMetalCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final auth = context.read<AuthProvider>();
    final taller = auth.tallerActivo;

    final precioBase = double.tryParse(_precioBaseCtrl.text.replaceAll(',', '.')) ?? taller.tablaPrecios.precioBase;
    final plazoDias = int.tryParse(_plazoDiasCtrl.text) ?? taller.plazoDias;
    final costoBordado = double.tryParse(_costoBordadoCtrl.text.replaceAll(',', '.')) ?? taller.tablaPrecios.costoBordado;
    final costoEstampado = double.tryParse(_costoEstampadoCtrl.text.replaceAll(',', '.')) ?? taller.tablaPrecios.costoEstampado;
    final cierreMetal = double.tryParse(_cierreMetalCtrl.text.replaceAll(',', '.')) ?? taller.tablaPrecios.costoCierreMetal;

    final nuevaTabla = taller.tablaPrecios.copyWith(
      precioBase: precioBase,
      costoBordado: costoBordado,
      costoEstampado: costoEstampado,
      costoCierreMetal: cierreMetal,
    );

    final tallerActualizado = taller.copyWith(
      plazoDias: plazoDias,
      tablaPrecios: nuevaTabla,
    );

    await TalleresRepository.instance.actualizarTaller(tallerActualizado);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('¡Tarifario actualizado en la nube con éxito!'),
          ],
        ),
        backgroundColor: SoraColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final taller = context.watch<AuthProvider>().tallerActivo;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner explicativo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SoraColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SoraColors.disabled.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: SoraColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Los valores aquí configurados son los que alimentan la calculadora automática cuando un cliente solicita cotización a ${taller.nombre}.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección 1: Precios Base y Tiempos
          Text('Precios Base y Tiempos', style: tt.titleMedium),
          const SizedBox(height: 12),
          _CampoEdicion(
            controller: _precioBaseCtrl,
            label: 'Precio Base por Prenda (S/.)',
            icono: Icons.attach_money,
            ayuda: 'Costo base antes de extras de tela o personalizaciones',
          ),
          const SizedBox(height: 12),
          _CampoEdicion(
            controller: _plazoDiasCtrl,
            label: 'Plazo Promedio de Confección (Días)',
            icono: Icons.calendar_today,
            ayuda: 'Días hábiles estimados para entregar un pedido de volumen estándar',
          ),

          const SizedBox(height: 24),
          // Sección 2: Personalizaciones y Técnicas
          Text('Costos de Personalización', style: tt.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CampoEdicion(
                  controller: _costoEstampadoCtrl,
                  label: 'Estampado (S/.)',
                  icono: Icons.brush,
                  ayuda: 'Por prenda',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoEdicion(
                  controller: _costoBordadoCtrl,
                  label: 'Bordado (S/.)',
                  icono: Icons.interests,
                  ayuda: 'Por prenda',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CampoEdicion(
            controller: _cierreMetalCtrl,
            label: 'Recargo por Cierre Metálico (S/.)',
            icono: Icons.link,
            ayuda: 'Aplica en casacas o buzos con cierre de metal',
          ),

          const SizedBox(height: 24),
          // Sección 3: Prendas que confecciona el taller
          Text('Prendas Habilitadas en tu Taller', style: tt.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: taller.prendas.map((prenda) {
              return FilterChip(
                selected: true,
                onSelected: (_) {},
                avatar: Icon(prenda.icono, size: 16),
                label: Text(prenda.label),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: SoraColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios de Tarifario', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _guardarCambios,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CampoEdicion extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final String ayuda;

  const _CampoEdicion({
    required this.controller,
    required this.label,
    required this.icono,
    required this.ayuda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icono, color: SoraColors.primary, size: 20),
            filled: true,
            fillColor: SoraColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(ayuda, style: const TextStyle(fontSize: 11, color: SoraColors.disabled)),
        ),
      ],
    );
  }
}
