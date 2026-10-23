import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Categorías generales de prenda
enum CategoriaPrenda {
  superior('Superior', 'Prendas para la parte superior del cuerpo'),
  inferior('Inferior', 'Pantalones, shorts y faldas'),
  vestido('Vestido', 'Vestidos de corte femenino y enterizos'),
  uniforme('Uniforme', 'Conjuntos completos e institucionales');

  const CategoriaPrenda(this.label, this.descripcion);
  final String label;
  final String descripcion;
}

/// Tipos de prenda disponibles
enum TipoPrenda {
  casaca('Casaca', 'Chaqueta con cierre o botones', Icons.checkroom, CategoriaPrenda.superior),
  polo('Polo', 'Camiseta de manga corta clásica', Icons.dry_cleaning, CategoriaPrenda.superior),
  polera('Polera', 'Buzo sin cierre, con capucha', Icons.airline_seat_flat, CategoriaPrenda.superior),
  camisa('Camisa', 'Camisa formal o casual con botones', Icons.view_sidebar_rounded, CategoriaPrenda.superior),
  pantalon('Pantalón', 'Pantalón largo casual o de vestir', Icons.accessibility_new, CategoriaPrenda.inferior),
  short('Short', 'Pantalón corto cómodo y fresco', Icons.straighten, CategoriaPrenda.inferior),
  falda('Falda', 'Falda casual, formal o acampanada', Icons.woman, CategoriaPrenda.inferior),
  vestido('Vestido', 'Vestido casual, de fiesta o corporativo', Icons.female, CategoriaPrenda.vestido),
  buzo('Buzo', 'Conjunto deportivo completo', Icons.sports, CategoriaPrenda.uniforme),
  uniforme('Uniforme', 'Uniforme laboral, escolar o institucional', Icons.badge, CategoriaPrenda.uniforme);

  const TipoPrenda(this.label, this.descripcion, this.icono, this.categoria);
  final String label;
  final String descripcion;
  final IconData icono;
  final CategoriaPrenda categoria;
}

/// Opciones de largo de prenda (para vestidos, pantalones, shorts, faldas)
enum LargoPrenda {
  corto('Corto / Mini', 'Por encima de la rodilla', Icons.short_text),
  midi('Midi / Medio', 'A la altura de la rodilla', Icons.menu),
  largo('Largo / Clásico', 'Largo completo hasta los tobillos', Icons.view_headline);

  const LargoPrenda(this.label, this.descripcion, this.icono);
  final String label;
  final String descripcion;
  final IconData icono;
}

/// Opciones de tipo de escote (para vestidos y prendas superiores)
enum TipoEscote {
  redondo('Escote redondo', 'Clásico y versátil', Icons.circle_outlined),
  enV('Escote en V', 'Estilizado y moderno', Icons.change_history),
  camisero('Cuello camisero', 'Con solapa estructurada', Icons.crop_square);

  const TipoEscote(this.label, this.descripcion, this.icono);
  final String label;
  final String descripcion;
  final IconData icono;
}

/// Opciones de tipo de manga (para vestidos y prendas superiores)
enum TipoManga {
  sinMangas('Sin mangas / Tirantes', 'Fresco y ligero', Icons.not_interested),
  corta('Manga corta', 'Estándar para clima cálido', Icons.horizontal_rule),
  larga('Manga larga', 'Cobertura completa hasta muñeca', Icons.linear_scale);

  const TipoManga(this.label, this.descripcion, this.icono);
  final String label;
  final String descripcion;
  final IconData icono;
}

/// Opciones de tipo de cintura (para pantalones, shorts y faldas)
enum TipoCintura {
  elastica('Cintura elástica', 'Con elástico y cordón ajustable', Icons.drag_handle),
  clasica('Pretina clásica', 'Con botón y pasadores para correa', Icons.radio_button_checked),
  tiroAlto('Tiro alto', 'Cintura alta reforzada y estilizada', Icons.vertical_align_top);

  const TipoCintura(this.label, this.descripcion, this.icono);
  final String label;
  final String descripcion;
  final IconData icono;
}

/// Tipos de tela disponibles
enum TipoTela {
  taslan('Taslan', 'Tela impermeable y resistente al viento, ideal para casacas deportivas e impermeables.', 'S/.12', 12.0),
  polar('Polar', 'Suave y abrigada, recomendada para prendas de invierno y climas fríos.', 'S/.8', 8.0),
  algodon('Algodón', 'Clásico y transpirable, perfecto para polos, vestidos y uso diario.', 'S/.6', 6.0),
  lino('Lino / Fresco', 'Fresco, elegante y con caída suave, ideal para vestidos y camisas.', 'S/.10', 10.0),
  denim('Dril / Denim', 'Resistente y duradero, ideal para pantalones, shorts y faldas.', 'S/.9', 9.0),
  gabardina('Gabardina', 'Estructurada de alta resistencia para uniformes y trabajo.', 'S/.11', 11.0);

  const TipoTela(this.label, this.descripcion, this.precioLabel, this.costoExtra);
  final String label;
  final String descripcion;
  final String precioLabel;
  final double costoExtra; // costo extra por prenda
}

/// Tipos de panel / corte
enum TipoPanel {
  liso('Panel liso', Icons.square),
  dividido('Panel dividido', Icons.view_column),
  diagonal('Panel diagonal', Icons.trending_up),
  rayas('Rayas verticales', Icons.view_stream);

  const TipoPanel(this.label, this.icono);
  final String label;
  final IconData icono;
}

/// Posición de logos/estampados
enum PosicionLogo {
  pecho('Pecho', 'Frontal izquierdo'),
  espalda('Espalda', 'Centro posterior'),
  mangas('Mangas / Pierna', 'Brazo o costado inferior');

  const PosicionLogo(this.label, this.descripcion);
  final String label;
  final String descripcion;
}

/// Técnicas de personalización disponibles
enum TecnicaConfeccion {
  bordado('Bordado', 'Bordado computarizado con relieve premium', Icons.brush_outlined),
  estampado('Estampado', 'Serigrafía / vinil textil DTF suave', Icons.color_lens_outlined);

  const TecnicaConfeccion(this.label, this.descripcion, this.icono);
  final String label;
  final String descripcion;
  final IconData icono;
}

/// Tamaño del logo/estampado
enum TamanoLogo {
  pequeno('Pequeño', '6 x 6 cm (pecho o manga)', 1.0),
  mediano('Mediano', '15 x 15 cm (pecho amplio o lateral)', 1.4),
  grande('Grande', '28 x 28 cm (espalda o frontal completo)', 1.9);

  const TamanoLogo(this.label, this.dimension, this.multiplicador);
  final String label;
  final String dimension;
  final double multiplicador;
}

/// Tallas disponibles
// ignore: constant_identifier_names
enum Talla { XS, S, M, L, XL, XXL }

/// Modelo de prenda personalizada
class DisenoPersonalizado {
  final TipoPrenda prenda;
  final Color colorPrincipal;
  final Color colorAccento;
  final Color colorMangas;
  final Color colorCuello;
  final TipoPanel panel;
  final List<PosicionLogo> posicionesLogo;
  final String textoLogo;
  final TipoTela tela;
  final bool tieneCierreMetal;
  final bool tieneCierrePlastico;
  final bool tieneBolsilloLateral;
  final bool tieneBolsilloPecho;
  final bool tieneBolsilloInterno;

  // Campos adaptativos según tipo de prenda
  final LargoPrenda largo;
  final TipoEscote tipoEscote;
  final TipoManga tipoManga;
  final TipoCintura tipoCintura;

  // Campos para logo e imagen personalizada
  final String? logoPath;
  final Uint8List? logoBytes;
  final TecnicaConfeccion tecnicaLogo;
  final TamanoLogo tamanoLogo;
  final PosicionLogo posicionLogo;

  const DisenoPersonalizado({
    required this.prenda,
    required this.colorPrincipal,
    required this.colorAccento,
    required this.colorMangas,
    required this.colorCuello,
    required this.panel,
    required this.posicionesLogo,
    required this.textoLogo,
    required this.tela,
    required this.tieneCierreMetal,
    required this.tieneCierrePlastico,
    required this.tieneBolsilloLateral,
    required this.tieneBolsilloPecho,
    required this.tieneBolsilloInterno,
    this.largo = LargoPrenda.midi,
    this.tipoEscote = TipoEscote.redondo,
    this.tipoManga = TipoManga.corta,
    this.tipoCintura = TipoCintura.clasica,
    this.logoPath,
    this.logoBytes,
    this.tecnicaLogo = TecnicaConfeccion.estampado,
    this.tamanoLogo = TamanoLogo.pequeno,
    this.posicionLogo = PosicionLogo.pecho,
  });

  bool get tieneLogo => (logoPath != null && logoPath!.isNotEmpty) || logoBytes != null;
  bool get tieneLogoOTexto => tieneLogo || textoLogo.trim().isNotEmpty || posicionesLogo.isNotEmpty;

  /// Costo extra del diseño (sin precio base ni tela)
  double get costoExtrasDiseno {
    double total = 0;
    if (tieneCierreMetal) total += 5.0;
    if (tieneCierrePlastico) total += 2.0;
    if (tieneBolsilloLateral) total += 3.0;
    if (tieneBolsilloPecho) total += 2.5;
    if (tieneBolsilloInterno) total += 4.0;
    if (tieneLogoOTexto) {
      final baseLogo = tecnicaLogo == TecnicaConfeccion.bordado ? 8.0 : 4.0;
      total += baseLogo * tamanoLogo.multiplicador;
    }
    return total;
  }

  DisenoPersonalizado copyWith({
    TipoPrenda? prenda,
    Color? colorPrincipal,
    Color? colorAccento,
    Color? colorMangas,
    Color? colorCuello,
    TipoPanel? panel,
    List<PosicionLogo>? posicionesLogo,
    String? textoLogo,
    TipoTela? tela,
    bool? tieneCierreMetal,
    bool? tieneCierrePlastico,
    bool? tieneBolsilloLateral,
    bool? tieneBolsilloPecho,
    bool? tieneBolsilloInterno,
    LargoPrenda? largo,
    TipoEscote? tipoEscote,
    TipoManga? tipoManga,
    TipoCintura? tipoCintura,
    String? logoPath,
    bool clearLogoPath = false,
    Uint8List? logoBytes,
    bool clearLogoBytes = false,
    TecnicaConfeccion? tecnicaLogo,
    TamanoLogo? tamanoLogo,
    PosicionLogo? posicionLogo,
  }) {
    return DisenoPersonalizado(
      prenda: prenda ?? this.prenda,
      colorPrincipal: colorPrincipal ?? this.colorPrincipal,
      colorAccento: colorAccento ?? this.colorAccento,
      colorMangas: colorMangas ?? this.colorMangas,
      colorCuello: colorCuello ?? this.colorCuello,
      panel: panel ?? this.panel,
      posicionesLogo: posicionesLogo ?? this.posicionesLogo,
      textoLogo: textoLogo ?? this.textoLogo,
      tela: tela ?? this.tela,
      tieneCierreMetal: tieneCierreMetal ?? this.tieneCierreMetal,
      tieneCierrePlastico: tieneCierrePlastico ?? this.tieneCierrePlastico,
      tieneBolsilloLateral: tieneBolsilloLateral ?? this.tieneBolsilloLateral,
      tieneBolsilloPecho: tieneBolsilloPecho ?? this.tieneBolsilloPecho,
      tieneBolsilloInterno: tieneBolsilloInterno ?? this.tieneBolsilloInterno,
      largo: largo ?? this.largo,
      tipoEscote: tipoEscote ?? this.tipoEscote,
      tipoManga: tipoManga ?? this.tipoManga,
      tipoCintura: tipoCintura ?? this.tipoCintura,
      logoPath: clearLogoPath ? null : (logoPath ?? this.logoPath),
      logoBytes: clearLogoBytes ? null : (logoBytes ?? this.logoBytes),
      tecnicaLogo: tecnicaLogo ?? this.tecnicaLogo,
      tamanoLogo: tamanoLogo ?? this.tamanoLogo,
      posicionLogo: posicionLogo ?? this.posicionLogo,
    );
  }

  /// Diseño vacío por defecto
  factory DisenoPersonalizado.inicial() => const DisenoPersonalizado(
        prenda: TipoPrenda.casaca,
        colorPrincipal: Color(0xFF1A3A5C),
        colorAccento: Color(0xFFB04F36),
        colorMangas: Color(0xFF1A3A5C),
        colorCuello: Color(0xFF2B1C14),
        panel: TipoPanel.liso,
        posicionesLogo: [PosicionLogo.pecho],
        textoLogo: '',
        tela: TipoTela.taslan,
        tieneCierreMetal: false,
        tieneCierrePlastico: false,
        tieneBolsilloLateral: false,
        tieneBolsilloPecho: false,
        tieneBolsilloInterno: false,
        largo: LargoPrenda.midi,
        tipoEscote: TipoEscote.redondo,
        tipoManga: TipoManga.corta,
        tipoCintura: TipoCintura.clasica,
        logoPath: null,
        logoBytes: null,
        tecnicaLogo: TecnicaConfeccion.estampado,
        tamanoLogo: TamanoLogo.pequeno,
        posicionLogo: PosicionLogo.pecho,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisenoPersonalizado &&
          runtimeType == other.runtimeType &&
          prenda == other.prenda &&
          colorPrincipal == other.colorPrincipal &&
          colorAccento == other.colorAccento &&
          colorMangas == other.colorMangas &&
          colorCuello == other.colorCuello &&
          panel == other.panel &&
          tela == other.tela &&
          largo == other.largo &&
          tipoEscote == other.tipoEscote &&
          tipoManga == other.tipoManga &&
          tipoCintura == other.tipoCintura &&
          logoPath == other.logoPath &&
          tecnicaLogo == other.tecnicaLogo &&
          tamanoLogo == other.tamanoLogo &&
          posicionLogo == other.posicionLogo &&
          textoLogo == other.textoLogo;

  @override
  int get hashCode => Object.hash(
        prenda,
        colorPrincipal,
        colorAccento,
        colorMangas,
        colorCuello,
        panel,
        tela,
        largo,
        tipoEscote,
        tipoManga,
        tipoCintura,
        logoPath,
        tecnicaLogo,
        tamanoLogo,
        posicionLogo,
        textoLogo,
      );
}
