import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/core/theme/sora_colors.dart';

/// Vista previa 2D simplificada de la prenda con silueta que cambia de color.
class PreviewPrenda extends StatefulWidget {
  final DisenoPersonalizado diseno;

  const PreviewPrenda({super.key, required this.diseno});

  @override
  State<PreviewPrenda> createState() => _PreviewPrendaState();
}

class _PreviewPrendaState extends State<PreviewPrenda> {
  bool _mostrarFrontal = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SoraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SoraColors.cardBorder),
      ),
      child: Column(
        children: [
          // Pestañas
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TabButton(
                  label: 'Frontal',
                  activo: _mostrarFrontal,
                  onTap: () => setState(() => _mostrarFrontal = true),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Posterior',
                  activo: !_mostrarFrontal,
                  onTap: () => setState(() => _mostrarFrontal = false),
                ),
              ],
            ),
          ),

          // Silueta
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _SiluetaPrenda(
                  key: ValueKey([
                    widget.diseno.prenda,
                    _mostrarFrontal,
                    widget.diseno.colorPrincipal.toARGB32(),
                    widget.diseno.colorAccento.toARGB32(),
                    widget.diseno.colorMangas.toARGB32(),
                    widget.diseno.colorCuello.toARGB32(),
                    widget.diseno.panel,
                    widget.diseno.largo,
                    widget.diseno.tipoEscote,
                    widget.diseno.tipoManga,
                    widget.diseno.tipoCintura,
                    widget.diseno.logoPath,
                    widget.diseno.logoBytes?.length,
                    widget.diseno.posicionLogo,
                    widget.diseno.tamanoLogo,
                    widget.diseno.textoLogo,
                  ].join('_')),
                  diseno: widget.diseno,
                  frontal: _mostrarFrontal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? SoraColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activo ? SoraColors.primary : SoraColors.cardBorder),
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
    );
  }
}

class _SiluetaPrenda extends StatelessWidget {
  final DisenoPersonalizado diseno;
  final bool frontal;

  const _SiluetaPrenda({super.key, required this.diseno, required this.frontal});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(110, 130),
            painter: _PrendaPainter(diseno: diseno, frontal: frontal),
          ),
          _LogoOverlay(diseno: diseno, frontal: frontal),
        ],
      ),
    );
  }
}

class _LogoOverlay extends StatelessWidget {
  final DisenoPersonalizado diseno;
  final bool frontal;

  const _LogoOverlay({required this.diseno, required this.frontal});

  @override
  Widget build(BuildContext context) {
    if (!diseno.tieneLogoOTexto) return const SizedBox.shrink();

    bool visible = false;
    double top = 44;
    double left = 46;

    final dim = switch (diseno.tamanoLogo) {
      TamanoLogo.pequeno => 16.0,
      TamanoLogo.mediano => 24.0,
      TamanoLogo.grande => 34.0,
    };

    switch (diseno.posicionLogo) {
      case PosicionLogo.pecho:
        if (frontal) {
          visible = true;
          if (diseno.prenda.categoria == CategoriaPrenda.inferior) {
            top = 52.0;
            left = 34.0;
          } else {
            top = 44.0;
            left = 46.0;
          }
        }
      case PosicionLogo.espalda:
        if (!frontal) {
          visible = true;
          if (diseno.prenda.categoria == CategoriaPrenda.inferior) {
            top = 46.0;
            left = 50.0;
          } else {
            top = 38.0;
            left = 46.0;
          }
        }
      case PosicionLogo.mangas:
        visible = true;
        if (diseno.prenda.categoria == CategoriaPrenda.inferior) {
          top = 58.0;
          left = 22.0;
        } else {
          top = 40.0;
          left = 16.0;
        }
    }

    if (!visible) return const SizedBox.shrink();

    return Positioned(
      top: top - dim / 2,
      left: left - dim / 2,
      child: Container(
        width: dim,
        height: dim,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: diseno.tecnicaLogo == TecnicaConfeccion.bordado
                ? const Color(0xFFD4845A)
                : const Color(0xFF2B1C14),
            width: 0.8,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: _buildContenido(),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (diseno.logoBytes != null) {
      return Image.memory(diseno.logoBytes!, fit: BoxFit.contain);
    } else if (diseno.logoPath != null && diseno.logoPath!.isNotEmpty) {
      return Image.file(File(diseno.logoPath!), fit: BoxFit.contain);
    } else if (diseno.textoLogo.isNotEmpty) {
      return Center(
        child: Text(
          diseno.textoLogo.length > 4 ? diseno.textoLogo.substring(0, 4) : diseno.textoLogo,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2B1C14),
          ),
        ),
      );
    } else {
      return Icon(
        diseno.tecnicaLogo == TecnicaConfeccion.bordado ? Icons.brush : Icons.palette,
        size: 10,
        color: const Color(0xFF7A3E27),
      );
    }
  }
}

class _PrendaPainter extends CustomPainter {
  final DisenoPersonalizado diseno;
  final bool frontal;

  _PrendaPainter({required this.diseno, required this.frontal});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (diseno.prenda.categoria) {
      case CategoriaPrenda.superior:
        _dibujarSuperior(canvas, w, h);
      case CategoriaPrenda.inferior:
        _dibujarInferior(canvas, w, h);
      case CategoriaPrenda.vestido:
        _dibujarVestido(canvas, w, h);
      case CategoriaPrenda.uniforme:
        _dibujarUniforme(canvas, w, h);
    }
  }

  Paint _paintColor(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  Paint _paintOutline() => Paint()
    ..color = Colors.black.withValues(alpha: 0.20)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.3;

  // -------------------------------------------------------------
  // CATEGORÍA: SUPERIOR (Polo, Camisa, Casaca, Polera)
  // -------------------------------------------------------------
  void _dibujarSuperior(Canvas canvas, double w, double h) {
    switch (diseno.prenda) {
      case TipoPrenda.casaca:
        _dibujarCasaca(canvas, w, h);
      case TipoPrenda.camisa:
        _dibujarCamisa(canvas, w, h);
      case TipoPrenda.polera:
        _dibujarPolera(canvas, w, h);
      case TipoPrenda.polo:
      default:
        _dibujarPolo(canvas, w, h);
    }
  }

  void _dibujarPolo(Canvas canvas, double w, double h) {
    final torso = Path()
      ..moveTo(w * 0.22, h * 0.16)
      ..lineTo(w * 0.20, h * 0.44)
      ..lineTo(w * 0.20, h * 0.94)
      ..lineTo(w * 0.80, h * 0.94)
      ..lineTo(w * 0.80, h * 0.44)
      ..lineTo(w * 0.78, h * 0.16)
      ..lineTo(w * 0.64, h * 0.11)
      ..quadraticBezierTo(w * 0.50, h * 0.21, w * 0.36, h * 0.11)
      ..close();
    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);
    canvas.drawPath(torso, _paintOutline());

    final mI = Path()
      ..moveTo(w * 0.22, h * 0.16)
      ..lineTo(w * 0.04, h * 0.38)
      ..lineTo(w * 0.20, h * 0.44)
      ..lineTo(w * 0.20, h * 0.28)
      ..close();
    final mD = Path()
      ..moveTo(w * 0.78, h * 0.16)
      ..lineTo(w * 0.96, h * 0.38)
      ..lineTo(w * 0.80, h * 0.44)
      ..lineTo(w * 0.80, h * 0.28)
      ..close();
    canvas.drawPath(mI, _paintColor(diseno.colorMangas));
    canvas.drawPath(mI, _paintOutline());
    canvas.drawPath(mD, _paintColor(diseno.colorMangas));
    canvas.drawPath(mD, _paintOutline());

    final cuello = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.15),
        width: w * 0.28,
        height: h * 0.10,
      ));
    canvas.drawPath(cuello, _paintColor(diseno.colorCuello));
    canvas.drawPath(cuello, _paintOutline());
  }

  void _dibujarCamisa(Canvas canvas, double w, double h) {
    final torso = Path()
      ..moveTo(w * 0.24, h * 0.16)
      ..lineTo(w * 0.20, h * 0.46)
      ..lineTo(w * 0.20, h * 0.94)
      ..lineTo(w * 0.80, h * 0.94)
      ..lineTo(w * 0.80, h * 0.46)
      ..lineTo(w * 0.76, h * 0.16)
      ..lineTo(w * 0.62, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.18, w * 0.38, h * 0.12)
      ..close();
    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);
    canvas.drawPath(torso, _paintOutline());

    // Mangas
    final mI = Path()
      ..moveTo(w * 0.24, h * 0.16)
      ..lineTo(w * 0.05, h * 0.42)
      ..lineTo(w * 0.20, h * 0.46)
      ..lineTo(w * 0.20, h * 0.26)
      ..close();
    final mD = Path()
      ..moveTo(w * 0.76, h * 0.16)
      ..lineTo(w * 0.95, h * 0.42)
      ..lineTo(w * 0.80, h * 0.46)
      ..lineTo(w * 0.80, h * 0.26)
      ..close();
    canvas.drawPath(mI, _paintColor(diseno.colorMangas));
    canvas.drawPath(mI, _paintOutline());
    canvas.drawPath(mD, _paintColor(diseno.colorMangas));
    canvas.drawPath(mD, _paintOutline());

    // Línea de botones frontal
    if (frontal) {
      final botonera = Path()
        ..moveTo(w * 0.47, h * 0.18)
        ..lineTo(w * 0.53, h * 0.18)
        ..lineTo(w * 0.53, h * 0.94)
        ..lineTo(w * 0.47, h * 0.94)
        ..close();
      canvas.drawPath(botonera, _paintColor(diseno.colorAccento.withValues(alpha: 0.35)));
      canvas.drawPath(botonera, _paintOutline());
    }

    // Cuello camisero
    final cuelloIzq = Path()
      ..moveTo(w * 0.36, h * 0.12)
      ..lineTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.46, h * 0.14)
      ..close();
    final cuelloDer = Path()
      ..moveTo(w * 0.64, h * 0.12)
      ..lineTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.54, h * 0.14)
      ..close();
    canvas.drawPath(cuelloIzq, _paintColor(diseno.colorCuello));
    canvas.drawPath(cuelloIzq, _paintOutline());
    canvas.drawPath(cuelloDer, _paintColor(diseno.colorCuello));
    canvas.drawPath(cuelloDer, _paintOutline());
  }

  void _dibujarCasaca(Canvas canvas, double w, double h) {
    final torso = Path()
      ..moveTo(w * 0.20, h * 0.18)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.18, h * 0.95)
      ..lineTo(w * 0.82, h * 0.95)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.80, h * 0.18)
      ..lineTo(w * 0.65, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.35, h * 0.12)
      ..close();

    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);
    canvas.drawPath(torso, _paintOutline());

    final mangaIzq = Path()
      ..moveTo(w * 0.20, h * 0.18)
      ..lineTo(w * 0.00, h * 0.42)
      ..lineTo(w * 0.18, h * 0.48)
      ..lineTo(w * 0.18, h * 0.24)
      ..close();
    final mangaDer = Path()
      ..moveTo(w * 0.80, h * 0.18)
      ..lineTo(w * 1.00, h * 0.42)
      ..lineTo(w * 0.82, h * 0.48)
      ..lineTo(w * 0.82, h * 0.24)
      ..close();

    canvas.drawPath(mangaIzq, _paintColor(diseno.colorMangas));
    canvas.drawPath(mangaIzq, _paintOutline());
    canvas.drawPath(mangaDer, _paintColor(diseno.colorMangas));
    canvas.drawPath(mangaDer, _paintOutline());

    // Cierre frontal
    if (frontal) {
      final zip = Path()
        ..moveTo(w * 0.49, h * 0.18)
        ..lineTo(w * 0.51, h * 0.18)
        ..lineTo(w * 0.51, h * 0.95)
        ..lineTo(w * 0.49, h * 0.95)
        ..close();
      canvas.drawPath(zip, _paintColor(diseno.colorAccento));
    }

    final cuelloPath = Path()
      ..moveTo(w * 0.35, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.65, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.06, w * 0.35, h * 0.12);
    canvas.drawPath(cuelloPath, _paintColor(diseno.colorCuello));
    canvas.drawPath(cuelloPath, _paintOutline());
  }

  void _dibujarPolera(Canvas canvas, double w, double h) {
    final torso = Path()
      ..moveTo(w * 0.20, h * 0.28)
      ..lineTo(w * 0.18, h * 0.54)
      ..lineTo(w * 0.18, h * 0.95)
      ..lineTo(w * 0.82, h * 0.95)
      ..lineTo(w * 0.82, h * 0.54)
      ..lineTo(w * 0.80, h * 0.28)
      ..lineTo(w * 0.64, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.30, w * 0.36, h * 0.22)
      ..close();
    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);
    canvas.drawPath(torso, _paintOutline());

    final capucha = Path()
      ..moveTo(w * 0.24, h * 0.28)
      ..quadraticBezierTo(w * 0.22, h * 0.02, w * 0.50, h * 0.01)
      ..quadraticBezierTo(w * 0.78, h * 0.02, w * 0.76, h * 0.28)
      ..lineTo(w * 0.64, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.30, w * 0.36, h * 0.22)
      ..close();
    canvas.drawPath(capucha, _paintColor(diseno.colorCuello));
    canvas.drawPath(capucha, _paintOutline());

    final mI = Path()
      ..moveTo(w * 0.20, h * 0.28)
      ..lineTo(w * 0.02, h * 0.48)
      ..lineTo(w * 0.18, h * 0.54)
      ..lineTo(w * 0.18, h * 0.34)
      ..close();
    final mD = Path()
      ..moveTo(w * 0.80, h * 0.28)
      ..lineTo(w * 0.98, h * 0.48)
      ..lineTo(w * 0.82, h * 0.54)
      ..lineTo(w * 0.82, h * 0.34)
      ..close();
    canvas.drawPath(mI, _paintColor(diseno.colorMangas));
    canvas.drawPath(mI, _paintOutline());
    canvas.drawPath(mD, _paintColor(diseno.colorMangas));
    canvas.drawPath(mD, _paintOutline());
  }

  // -------------------------------------------------------------
  // CATEGORÍA: INFERIOR (Pantalón, Short, Falda)
  // -------------------------------------------------------------
  void _dibujarInferior(Canvas canvas, double w, double h) {
    if (diseno.prenda == TipoPrenda.falda) {
      _dibujarFalda(canvas, w, h);
    } else if (diseno.prenda == TipoPrenda.short) {
      _dibujarShort(canvas, w, h);
    } else {
      _dibujarPantalon(canvas, w, h);
    }
  }

  void _dibujarPantalon(Canvas canvas, double w, double h) {
    final largoFactor = diseno.largo == LargoPrenda.corto ? 0.65 : (diseno.largo == LargoPrenda.midi ? 0.82 : 0.96);

    // Pretina
    final pretina = Path()
      ..moveTo(w * 0.22, h * 0.14)
      ..lineTo(w * 0.78, h * 0.14)
      ..lineTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.22, h * 0.24)
      ..close();
    canvas.drawPath(pretina, _paintColor(diseno.colorCuello));
    canvas.drawPath(pretina, _paintOutline());

    // Piernas del pantalón
    final piernas = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.18, h * largoFactor)
      ..lineTo(w * 0.45, h * largoFactor)
      ..lineTo(w * 0.50, h * 0.52)
      ..lineTo(w * 0.55, h * largoFactor)
      ..lineTo(w * 0.82, h * largoFactor)
      ..lineTo(w * 0.78, h * 0.24)
      ..close();
    canvas.drawPath(piernas, _paintColor(diseno.colorPrincipal));

    // Franja lateral o bolsillos de acento
    final franjaIzq = Path()
      ..moveTo(w * 0.22, h * 0.24)
      ..lineTo(w * 0.26, h * 0.24)
      ..lineTo(w * 0.23, h * largoFactor)
      ..lineTo(w * 0.18, h * largoFactor)
      ..close();
    final franjaDer = Path()
      ..moveTo(w * 0.78, h * 0.24)
      ..lineTo(w * 0.74, h * 0.24)
      ..lineTo(w * 0.77, h * largoFactor)
      ..lineTo(w * 0.82, h * largoFactor)
      ..close();
    canvas.drawPath(franjaIzq, _paintColor(diseno.colorAccento));
    canvas.drawPath(franjaDer, _paintColor(diseno.colorAccento));

    canvas.drawPath(piernas, _paintOutline());

    // Bastas inferiores
    final bastaIzq = Path()
      ..addRect(Rect.fromLTWH(w * 0.18, h * largoFactor - h * 0.04, w * 0.27, h * 0.04));
    final bastaDer = Path()
      ..addRect(Rect.fromLTWH(w * 0.55, h * largoFactor - h * 0.04, w * 0.27, h * 0.04));
    canvas.drawPath(bastaIzq, _paintColor(diseno.colorMangas.withValues(alpha: 0.5)));
    canvas.drawPath(bastaDer, _paintColor(diseno.colorMangas.withValues(alpha: 0.5)));
  }

  void _dibujarShort(Canvas canvas, double w, double h) {
    const largoFactor = 0.62;

    // Pretina
    final pretina = Path()
      ..moveTo(w * 0.20, h * 0.16)
      ..lineTo(w * 0.80, h * 0.16)
      ..lineTo(w * 0.80, h * 0.26)
      ..lineTo(w * 0.20, h * 0.26)
      ..close();
    canvas.drawPath(pretina, _paintColor(diseno.colorCuello));
    canvas.drawPath(pretina, _paintOutline());

    // Piernas del short
    final piernas = Path()
      ..moveTo(w * 0.20, h * 0.26)
      ..lineTo(w * 0.14, h * largoFactor)
      ..lineTo(w * 0.46, h * largoFactor)
      ..lineTo(w * 0.50, h * 0.44)
      ..lineTo(w * 0.54, h * largoFactor)
      ..lineTo(w * 0.86, h * largoFactor)
      ..lineTo(w * 0.80, h * 0.26)
      ..close();
    canvas.drawPath(piernas, _paintColor(diseno.colorPrincipal));

    // Acento lateral
    final acentoIzq = Path()
      ..moveTo(w * 0.20, h * 0.26)
      ..lineTo(w * 0.25, h * 0.26)
      ..lineTo(w * 0.19, h * largoFactor)
      ..lineTo(w * 0.14, h * largoFactor)
      ..close();
    final acentoDer = Path()
      ..moveTo(w * 0.80, h * 0.26)
      ..lineTo(w * 0.75, h * 0.26)
      ..lineTo(w * 0.81, h * largoFactor)
      ..lineTo(w * 0.86, h * largoFactor)
      ..close();
    canvas.drawPath(acentoIzq, _paintColor(diseno.colorAccento));
    canvas.drawPath(acentoDer, _paintColor(diseno.colorAccento));

    canvas.drawPath(piernas, _paintOutline());
  }

  void _dibujarFalda(Canvas canvas, double w, double h) {
    final largoFactor = diseno.largo == LargoPrenda.corto ? 0.60 : (diseno.largo == LargoPrenda.midi ? 0.78 : 0.94);
    final anchoFalda = diseno.largo == LargoPrenda.corto ? 0.88 : (diseno.largo == LargoPrenda.midi ? 0.92 : 0.96);

    // Pretina
    final pretina = Path()
      ..moveTo(w * 0.28, h * 0.18)
      ..lineTo(w * 0.72, h * 0.18)
      ..lineTo(w * 0.70, h * 0.28)
      ..lineTo(w * 0.30, h * 0.28)
      ..close();
    canvas.drawPath(pretina, _paintColor(diseno.colorCuello));
    canvas.drawPath(pretina, _paintOutline());

    // Vuelo de la falda
    final falda = Path()
      ..moveTo(w * 0.30, h * 0.28)
      ..quadraticBezierTo(w * 0.18, h * (0.28 + largoFactor) / 2, w * (1.0 - anchoFalda) / 2 + 0.05, h * largoFactor)
      ..quadraticBezierTo(w * 0.50, h * (largoFactor + 0.03), w * anchoFalda, h * largoFactor)
      ..quadraticBezierTo(w * 0.82, h * (0.28 + largoFactor) / 2, w * 0.70, h * 0.28)
      ..close();
    canvas.drawPath(falda, _paintColor(diseno.colorPrincipal));

    // Tablones / corte acento
    final acentoMedio = Path()
      ..moveTo(w * 0.46, h * 0.28)
      ..lineTo(w * 0.44, h * largoFactor)
      ..lineTo(w * 0.56, h * largoFactor)
      ..lineTo(w * 0.54, h * 0.28)
      ..close();
    canvas.drawPath(acentoMedio, _paintColor(diseno.colorAccento.withValues(alpha: 0.35)));

    canvas.drawPath(falda, _paintOutline());
  }

  // -------------------------------------------------------------
  // CATEGORÍA: VESTIDO
  // -------------------------------------------------------------
  void _dibujarVestido(Canvas canvas, double w, double h) {
    final largoFactor = diseno.largo == LargoPrenda.corto ? 0.68 : (diseno.largo == LargoPrenda.midi ? 0.84 : 0.96);

    // Torso superior
    final torso = Path()
      ..moveTo(w * 0.32, h * 0.14)
      ..lineTo(w * 0.22, h * 0.26)
      ..lineTo(w * 0.30, h * 0.46)
      ..lineTo(w * 0.70, h * 0.46)
      ..lineTo(w * 0.78, h * 0.26)
      ..lineTo(w * 0.68, h * 0.14)
      ..close();
    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);

    // Mangas según tipoManga
    if (diseno.tipoManga != TipoManga.sinMangas) {
      final mangaLargo = diseno.tipoManga == TipoManga.larga ? 0.50 : 0.32;
      final mIzq = Path()
        ..moveTo(w * 0.32, h * 0.14)
        ..lineTo(w * 0.14, h * mangaLargo)
        ..lineTo(w * 0.24, h * (mangaLargo + 0.05))
        ..lineTo(w * 0.28, h * 0.32)
        ..close();
      final mDer = Path()
        ..moveTo(w * 0.68, h * 0.14)
        ..lineTo(w * 0.86, h * mangaLargo)
        ..lineTo(w * 0.76, h * (mangaLargo + 0.05))
        ..lineTo(w * 0.72, h * 0.32)
        ..close();
      canvas.drawPath(mIzq, _paintColor(diseno.colorMangas));
      canvas.drawPath(mIzq, _paintOutline());
      canvas.drawPath(mDer, _paintColor(diseno.colorMangas));
      canvas.drawPath(mDer, _paintOutline());
    }

    // Falda del vestido
    final faldaVestido = Path()
      ..moveTo(w * 0.30, h * 0.46)
      ..lineTo(w * 0.12, h * largoFactor)
      ..quadraticBezierTo(w * 0.50, h * (largoFactor + 0.03), w * 0.88, h * largoFactor)
      ..lineTo(w * 0.70, h * 0.46)
      ..close();
    canvas.drawPath(faldaVestido, _paintColor(diseno.colorPrincipal));
    canvas.drawPath(faldaVestido, _paintOutline());
    canvas.drawPath(torso, _paintOutline());

    // Cinturón o pretina acento
    final cinturon = Path()
      ..moveTo(w * 0.29, h * 0.43)
      ..lineTo(w * 0.71, h * 0.43)
      ..lineTo(w * 0.70, h * 0.48)
      ..lineTo(w * 0.30, h * 0.48)
      ..close();
    canvas.drawPath(cinturon, _paintColor(diseno.colorAccento));
    canvas.drawPath(cinturon, _paintOutline());

    // Escote según tipoEscote
    if (diseno.tipoEscote == TipoEscote.enV) {
      final escoteV = Path()
        ..moveTo(w * 0.38, h * 0.14)
        ..lineTo(w * 0.50, h * 0.28)
        ..lineTo(w * 0.62, h * 0.14)
        ..close();
      canvas.drawPath(escoteV, _paintColor(diseno.colorCuello));
      canvas.drawPath(escoteV, _paintOutline());
    } else {
      final escoteRedondo = Path()
        ..moveTo(w * 0.36, h * 0.14)
        ..quadraticBezierTo(w * 0.50, h * 0.25, w * 0.64, h * 0.14)
        ..quadraticBezierTo(w * 0.50, h * 0.11, w * 0.36, h * 0.14);
      canvas.drawPath(escoteRedondo, _paintColor(diseno.colorCuello));
      canvas.drawPath(escoteRedondo, _paintOutline());
    }
  }

  // -------------------------------------------------------------
  // CATEGORÍA: UNIFORME / CONJUNTO (Buzo, Uniforme institucional)
  // -------------------------------------------------------------
  void _dibujarUniforme(Canvas canvas, double w, double h) {
    // Casaca / Chaqueta superior
    final torso = Path()
      ..moveTo(w * 0.22, h * 0.16)
      ..lineTo(w * 0.18, h * 0.46)
      ..lineTo(w * 0.18, h * 0.56)
      ..lineTo(w * 0.82, h * 0.56)
      ..lineTo(w * 0.82, h * 0.46)
      ..lineTo(w * 0.78, h * 0.16)
      ..lineTo(w * 0.64, h * 0.12)
      ..quadraticBezierTo(w * 0.50, h * 0.20, w * 0.36, h * 0.12)
      ..close();
    canvas.drawPath(torso, _paintColor(diseno.colorPrincipal));
    _dibujarPanel(canvas, torso, w, h);
    canvas.drawPath(torso, _paintOutline());

    // Mangas superiores
    final mI = Path()
      ..moveTo(w * 0.22, h * 0.16)
      ..lineTo(w * 0.04, h * 0.40)
      ..lineTo(w * 0.18, h * 0.46)
      ..lineTo(w * 0.18, h * 0.26)
      ..close();
    final mD = Path()
      ..moveTo(w * 0.78, h * 0.16)
      ..lineTo(w * 0.96, h * 0.40)
      ..lineTo(w * 0.82, h * 0.46)
      ..lineTo(w * 0.82, h * 0.26)
      ..close();
    canvas.drawPath(mI, _paintColor(diseno.colorMangas));
    canvas.drawPath(mI, _paintOutline());
    canvas.drawPath(mD, _paintColor(diseno.colorMangas));
    canvas.drawPath(mD, _paintOutline());

    // Cuello
    final cuello = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.14),
        width: w * 0.26,
        height: h * 0.08,
      ));
    canvas.drawPath(cuello, _paintColor(diseno.colorCuello));
    canvas.drawPath(cuello, _paintOutline());

    // Pantalón coordinado
    final pant = Path()
      ..moveTo(w * 0.20, h * 0.55)
      ..lineTo(w * 0.19, h * 0.95)
      ..lineTo(w * 0.45, h * 0.95)
      ..lineTo(w * 0.50, h * 0.72)
      ..lineTo(w * 0.55, h * 0.95)
      ..lineTo(w * 0.81, h * 0.95)
      ..lineTo(w * 0.80, h * 0.55)
      ..close();
    canvas.drawPath(pant, _paintColor(diseno.colorPrincipal));

    // Franja lateral distintiva en pantalón
    final rayaIzq = Path()
      ..moveTo(w * 0.20, h * 0.55)
      ..lineTo(w * 0.24, h * 0.55)
      ..lineTo(w * 0.23, h * 0.95)
      ..lineTo(w * 0.19, h * 0.95)
      ..close();
    final rayaDer = Path()
      ..moveTo(w * 0.80, h * 0.55)
      ..lineTo(w * 0.76, h * 0.55)
      ..lineTo(w * 0.77, h * 0.95)
      ..lineTo(w * 0.81, h * 0.95)
      ..close();
    canvas.drawPath(rayaIzq, _paintColor(diseno.colorAccento));
    canvas.drawPath(rayaDer, _paintColor(diseno.colorAccento));

    canvas.drawPath(pant, _paintOutline());
  }

  Paint _paintCostura() => Paint()
    ..color = Colors.black.withValues(alpha: 0.28)
    ..strokeWidth = 1.2
    ..style = PaintingStyle.stroke;

  void _dibujarPanel(Canvas canvas, Path clipPath, double w, double h) {
    if (diseno.panel == TipoPanel.liso) return;

    canvas.save();
    canvas.clipPath(clipPath);

    switch (diseno.panel) {
      case TipoPanel.liso:
        break;

      case TipoPanel.dividido:
        // Mitad derecha con color de acento sólido (dos zonas de distinto color)
        final mitadDer = Rect.fromLTWH(w * 0.50, 0, w * 0.60, h);
        canvas.drawRect(mitadDer, _paintColor(diseno.colorAccento));
        // Línea vertical central de corte/costura
        canvas.drawLine(
          Offset(w * 0.50, 0),
          Offset(w * 0.50, h),
          _paintCostura(),
        );

      case TipoPanel.diagonal:
        // Franja diagonal de acento cruzando el pecho y torso
        final diag = Path()
          ..moveTo(w * 0.12, h * 0.12)
          ..lineTo(w * 0.48, h * 0.12)
          ..lineTo(w * 0.88, h * 0.96)
          ..lineTo(w * 0.52, h * 0.96)
          ..close();
        canvas.drawPath(diag, _paintColor(diseno.colorAccento));
        // Bordes de costura para la franja diagonal
        final borde1 = Path()
          ..moveTo(w * 0.12, h * 0.12)
          ..lineTo(w * 0.52, h * 0.96);
        final borde2 = Path()
          ..moveTo(w * 0.48, h * 0.12)
          ..lineTo(w * 0.88, h * 0.96);
        canvas.drawPath(borde1, _paintCostura());
        canvas.drawPath(borde2, _paintCostura());

      case TipoPanel.rayas:
        // Franjas verticales de acento
        final anchoFranja = w * 0.08;
        final posicionesX = [w * 0.32, w * 0.46, w * 0.60];
        for (final x in posicionesX) {
          final rect = Rect.fromLTWH(x, 0, anchoFranja, h);
          canvas.drawRect(rect, _paintColor(diseno.colorAccento));
          canvas.drawLine(Offset(x, 0), Offset(x, h), _paintCostura());
          canvas.drawLine(Offset(x + anchoFranja, 0), Offset(x + anchoFranja, h), _paintCostura());
        }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_PrendaPainter old) => true;
}
