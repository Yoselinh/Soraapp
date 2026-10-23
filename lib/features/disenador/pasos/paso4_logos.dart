import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sora_app/core/theme/sora_colors.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/features/disenador/disenador_provider.dart';

/// Paso 4: Subir logo, elegir técnica (bordado/estampado), tamaño y posición
class Paso4Logos extends StatelessWidget {
  const Paso4Logos({super.key});

  Future<void> _subirLogo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (!context.mounted) return;
        final prov = context.read<DisenadorProvider>();
        prov.actualizarDiseno(
          prov.diseno.copyWith(
            logoPath: pickedFile.path,
            logoBytes: bytes,
            posicionesLogo: prov.diseno.posicionesLogo.isEmpty
                ? [prov.diseno.posicionLogo]
                : prov.diseno.posicionesLogo,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cargar la imagen: $e'),
            backgroundColor: SoraColors.error,
          ),
        );
      }
    }
  }

  void _quitarLogo(BuildContext context) {
    final prov = context.read<DisenadorProvider>();
    prov.actualizarDiseno(
      prov.diseno.copyWith(
        clearLogoPath: true,
        clearLogoBytes: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DisenadorProvider>();
    final diseno = provider.diseno;
    final tt = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Logo o diseño gráfico', style: tt.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Sube tu logotipo o arte para confeccionarlo en tus prendas.',
            style: tt.bodyMedium,
          ),
          const SizedBox(height: 16),

          // 1. SECCIÓN: SUBIR LOGO (IMAGE PICKER)
          if (!diseno.tieneLogo)
            _BotonSubirLogo(onTap: () => _subirLogo(context))
          else
            _VistaPreviaLogoCard(
              diseno: diseno,
              onCambiar: () => _subirLogo(context),
              onQuitar: () => _quitarLogo(context),
            ),

          const SizedBox(height: 24),

          // 2. SECCIÓN: TÉCNICA (BORDADO O ESTAMPADO)
          Text('Técnica de personalización', style: tt.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'El bordado brinda relieve premium pero tiene mayor costo que el estampado.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8D7060)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TecnicaOptionCard(
                  tecnica: TecnicaConfeccion.bordado,
                  seleccionada: diseno.tecnicaLogo == TecnicaConfeccion.bordado,
                  precioNota: 'Mayor costo',
                  onTap: () => provider.actualizarDiseno(
                    diseno.copyWith(tecnicaLogo: TecnicaConfeccion.bordado),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TecnicaOptionCard(
                  tecnica: TecnicaConfeccion.estampado,
                  seleccionada: diseno.tecnicaLogo == TecnicaConfeccion.estampado,
                  precioNota: 'Económico',
                  onTap: () => provider.actualizarDiseno(
                    diseno.copyWith(tecnicaLogo: TecnicaConfeccion.estampado),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 3. SECCIÓN: TAMAÑO DEL LOGO
          Text('Tamaño del logo', style: tt.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Selecciona las dimensiones aproximadas sobre la prenda.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8D7060)),
          ),
          const SizedBox(height: 12),
          Row(
            children: TamanoLogo.values.map((tamano) {
              final activo = diseno.tamanoLogo == tamano;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _TamanoOptionCard(
                    tamano: tamano,
                    activo: activo,
                    onTap: () => provider.actualizarDiseno(
                      diseno.copyWith(tamanoLogo: tamano),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 4. SECCIÓN: POSICIÓN DEL LOGO
          Text('Posición en la prenda', style: tt.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Elige dónde se ubicará el logo en la silueta.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8D7060)),
          ),
          const SizedBox(height: 12),
          ...PosicionLogo.values.map((pos) {
            final activo = diseno.posicionLogo == pos;
            return GestureDetector(
              onTap: () {
                final lista = [pos];
                provider.actualizarDiseno(
                  diseno.copyWith(
                    posicionLogo: pos,
                    posicionesLogo: lista,
                  ),
                );
              },
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
                    Icon(
                      activo ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: activo ? SoraColors.primary : const Color(0xFF8D7060),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pos.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: activo ? SoraColors.primary : SoraColors.onBackground,
                            ),
                          ),
                          Text(
                            pos.descripcion,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8D7060)),
                          ),
                        ],
                      ),
                    ),
                    if (activo)
                      const Icon(Icons.check_circle, color: SoraColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // 5. TEXTO DEL LOGO / ESLOGAN (OPCIONAL)
          Text('Texto o eslogan (opcional)', style: tt.titleMedium),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: diseno.textoLogo,
            decoration: const InputDecoration(
              hintText: 'Ej: SORA, Marca o Nombre...',
              prefixIcon: Icon(Icons.text_fields, color: SoraColors.primary),
            ),
            maxLength: 20,
            onChanged: (val) => provider.actualizarDiseno(
              diseno.copyWith(textoLogo: val),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonSubirLogo extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonSubirLogo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: SoraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SoraColors.primary,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: SoraColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: SoraColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subir logo desde galería',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: SoraColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Formatos PNG o JPG con fondo transparente recomendado',
              style: TextStyle(fontSize: 11, color: Color(0xFF8D7060)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VistaPreviaLogoCard extends StatelessWidget {
  final DisenoPersonalizado diseno;
  final VoidCallback onCambiar;
  final VoidCallback onQuitar;

  const _VistaPreviaLogoCard({
    required this.diseno,
    required this.onCambiar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoraColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          // Imagen miniatura
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              color: Colors.white,
              child: diseno.logoBytes != null
                  ? Image.memory(
                      diseno.logoBytes!,
                      fit: BoxFit.contain,
                    )
                  : (diseno.logoPath != null
                      ? Image.file(
                          File(diseno.logoPath!),
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.image, color: SoraColors.primary)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: SoraColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Logo cargado',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: SoraColors.onBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${diseno.tecnicaLogo.label} · ${diseno.tamanoLogo.label}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF8D7060)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    GestureDetector(
                      onTap: onCambiar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SoraColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_horiz, size: 14, color: SoraColors.primary),
                            SizedBox(width: 4),
                            Text('Cambiar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SoraColors.primary)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onQuitar,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SoraColors.error.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline, size: 14, color: SoraColors.error),
                            SizedBox(width: 4),
                            Text('Quitar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SoraColors.error)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TecnicaOptionCard extends StatelessWidget {
  final TecnicaConfeccion tecnica;
  final bool seleccionada;
  final String precioNota;
  final VoidCallback onTap;

  const _TecnicaOptionCard({
    required this.tecnica,
    required this.seleccionada,
    required this.precioNota,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionada ? SoraColors.primary.withValues(alpha: 0.12) : SoraColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada ? SoraColors.primary : SoraColors.cardBorder,
            width: seleccionada ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tecnica.icono,
                  color: seleccionada ? SoraColors.primary : const Color(0xFF8D7060),
                  size: 24,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: seleccionada
                        ? SoraColors.primary.withValues(alpha: 0.15)
                        : SoraColors.cardBorder.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    precioNota,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: seleccionada ? SoraColors.primary : const Color(0xFF8D7060),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tecnica.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: seleccionada ? SoraColors.primary : SoraColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tecnica.descripcion,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TamanoOptionCard extends StatelessWidget {
  final TamanoLogo tamano;
  final bool activo;
  final VoidCallback onTap;

  const _TamanoOptionCard({
    required this.tamano,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: activo ? SoraColors.primary.withValues(alpha: 0.12) : SoraColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo ? SoraColors.primary : SoraColors.cardBorder,
            width: activo ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              tamano.label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: activo ? SoraColors.primary : SoraColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tamano.dimension.split(' ').first,
              style: const TextStyle(fontSize: 10, color: Color(0xFF8D7060)),
            ),
          ],
        ),
      ),
    );
  }
}
