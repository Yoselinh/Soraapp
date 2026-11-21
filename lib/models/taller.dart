import 'diseno_personalizado.dart';

/// Tabla de precios de un taller específico.
/// Permite calcular el total de una prenda de forma independiente por taller.
class TablaPrecios {
  final double precioBase; // precio base por prenda
  final double multiplicadorTela; // factor sobre el costoExtra de la tela
  final double multiplicadorEstampado; // factor por cada posición de logo
  final double costoCierreMetal;
  final double costoCierrePlastico;
  final double costoBolsilloLateral;
  final double costoBolsilloPecho;
  final double costoBolsilloInterno;
  final double costoBordado;
  final double costoEstampado;

  const TablaPrecios({
    required this.precioBase,
    required this.multiplicadorTela,
    required this.multiplicadorEstampado,
    required this.costoCierreMetal,
    required this.costoCierrePlastico,
    required this.costoBolsilloLateral,
    required this.costoBolsilloPecho,
    required this.costoBolsilloInterno,
    this.costoBordado = 6.0,
    this.costoEstampado = 3.5,
  });

  /// Calcula el costo por unidad para un diseño dado
  double calcularPorUnidad(DisenoPersonalizado diseno) {
    double total = precioBase;
    total += diseno.tela.costoExtra * multiplicadorTela;

    // Costo de personalización (bordado o estampado) propio de cada taller
    if (diseno.tieneLogoOTexto) {
      final costoTecnica = diseno.tecnicaLogo == TecnicaConfeccion.bordado
          ? costoBordado
          : costoEstampado;
      total += costoTecnica * diseno.tamanoLogo.multiplicador;
    }

    if (diseno.tieneCierreMetal) total += costoCierreMetal;
    if (diseno.tieneCierrePlastico) total += costoCierrePlastico;
    if (diseno.tieneBolsilloLateral) total += costoBolsilloLateral;
    if (diseno.tieneBolsilloPecho) total += costoBolsilloPecho;
    if (diseno.tieneBolsilloInterno) total += costoBolsilloInterno;
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'precioBase': precioBase,
      'multiplicadorTela': multiplicadorTela,
      'multiplicadorEstampado': multiplicadorEstampado,
      'costoCierreMetal': costoCierreMetal,
      'costoCierrePlastico': costoCierrePlastico,
      'costoBolsilloLateral': costoBolsilloLateral,
      'costoBolsilloPecho': costoBolsilloPecho,
      'costoBolsilloInterno': costoBolsilloInterno,
      'costoBordado': costoBordado,
      'costoEstampado': costoEstampado,
    };
  }

  factory TablaPrecios.fromMap(Map<String, dynamic> map) {
    return TablaPrecios(
      precioBase: (map['precioBase'] as num?)?.toDouble() ?? 40.0,
      multiplicadorTela: (map['multiplicadorTela'] as num?)?.toDouble() ?? 1.0,
      multiplicadorEstampado: (map['multiplicadorEstampado'] as num?)?.toDouble() ?? 3.5,
      costoCierreMetal: (map['costoCierreMetal'] as num?)?.toDouble() ?? 5.0,
      costoCierrePlastico: (map['costoCierrePlastico'] as num?)?.toDouble() ?? 3.0,
      costoBolsilloLateral: (map['costoBolsilloLateral'] as num?)?.toDouble() ?? 4.0,
      costoBolsilloPecho: (map['costoBolsilloPecho'] as num?)?.toDouble() ?? 3.0,
      costoBolsilloInterno: (map['costoBolsilloInterno'] as num?)?.toDouble() ?? 4.5,
      costoBordado: (map['costoBordado'] as num?)?.toDouble() ?? 6.0,
      costoEstampado: (map['costoEstampado'] as num?)?.toDouble() ?? 3.5,
    );
  }

  TablaPrecios copyWith({
    double? precioBase,
    double? multiplicadorTela,
    double? multiplicadorEstampado,
    double? costoCierreMetal,
    double? costoCierrePlastico,
    double? costoBolsilloLateral,
    double? costoBolsilloPecho,
    double? costoBolsilloInterno,
    double? costoBordado,
    double? costoEstampado,
  }) {
    return TablaPrecios(
      precioBase: precioBase ?? this.precioBase,
      multiplicadorTela: multiplicadorTela ?? this.multiplicadorTela,
      multiplicadorEstampado: multiplicadorEstampado ?? this.multiplicadorEstampado,
      costoCierreMetal: costoCierreMetal ?? this.costoCierreMetal,
      costoCierrePlastico: costoCierrePlastico ?? this.costoCierrePlastico,
      costoBolsilloLateral: costoBolsilloLateral ?? this.costoBolsilloLateral,
      costoBolsilloPecho: costoBolsilloPecho ?? this.costoBolsilloPecho,
      costoBolsilloInterno: costoBolsilloInterno ?? this.costoBolsilloInterno,
      costoBordado: costoBordado ?? this.costoBordado,
      costoEstampado: costoEstampado ?? this.costoEstampado,
    );
  }
}

/// Modelo de un taller de confección
class Taller {
  final String id;
  final String nombre;
  final String ciudad;
  final double calificacion; // 0.0 = sin calificaciones aún
  final int totalCalificaciones; // conteo de calificaciones reales hechas por clientes
  final int plazoDias; // días de entrega
  final TablaPrecios tablaPrecios;
  final String descripcion;
  final List<TipoPrenda> prendas;
  final List<TecnicaConfeccion> tecnicas;
  final String direccion;
  final String telefono;
  final int pedidosCompletados;

  const Taller({
    required this.id,
    required this.nombre,
    required this.ciudad,
    this.calificacion = 0.0,
    this.totalCalificaciones = 0,
    required this.plazoDias,
    required this.tablaPrecios,
    required this.descripcion,
    required this.prendas,
    required this.tecnicas,
    this.direccion = 'Zona Industrial Textil',
    this.telefono = '+51 987 654 321',
    this.pedidosCompletados = 0,
  });

  bool get esNuevo => totalCalificaciones == 0 || calificacion == 0.0;

  bool confecciona(TipoPrenda prenda) => prendas.contains(prenda);
  bool tieneTecnica(TecnicaConfeccion tecnica) => tecnicas.contains(tecnica);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'ciudad': ciudad,
      'calificacion': calificacion,
      'totalCalificaciones': totalCalificaciones,
      'plazoDias': plazoDias,
      'tablaPrecios': tablaPrecios.toMap(),
      'descripcion': descripcion,
      'prendas': prendas.map((p) => p.name).toList(),
      'tecnicas': tecnicas.map((t) => t.name).toList(),
      'direccion': direccion,
      'telefono': telefono,
      'pedidosCompletados': pedidosCompletados,
    };
  }

  factory Taller.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Taller(
      id: docId ?? (map['id'] as String? ?? 'taller_nuevo'),
      nombre: map['nombre'] as String? ?? '',
      ciudad: map['ciudad'] as String? ?? 'Lima',
      calificacion: (map['calificacion'] as num?)?.toDouble() ?? 0.0,
      totalCalificaciones: (map['totalCalificaciones'] as num?)?.toInt() ?? 0,
      plazoDias: map['plazoDias'] as int? ?? 10,
      tablaPrecios: map['tablaPrecios'] != null
          ? TablaPrecios.fromMap(Map<String, dynamic>.from(map['tablaPrecios']))
          : const TablaPrecios(
              precioBase: 40.0,
              multiplicadorTela: 1.0,
              multiplicadorEstampado: 3.5,
              costoCierreMetal: 5.0,
              costoCierrePlastico: 3.0,
              costoBolsilloLateral: 4.0,
              costoBolsilloPecho: 3.0,
              costoBolsilloInterno: 4.5,
            ),
      descripcion: map['descripcion'] as String? ?? '',
      prendas: (map['prendas'] as List<dynamic>?)
              ?.map((p) => TipoPrenda.values.firstWhere(
                    (e) => e.name == p,
                    orElse: () => TipoPrenda.polo,
                  ))
              .toList() ??
          [TipoPrenda.polo],
      tecnicas: (map['tecnicas'] as List<dynamic>?)
              ?.map((t) => TecnicaConfeccion.values.firstWhere(
                    (e) => e.name == t,
                    orElse: () => TecnicaConfeccion.estampado,
                  ))
              .toList() ??
          [TecnicaConfeccion.estampado],
      direccion: map['direccion'] as String? ?? 'Zona Industrial Textil',
      telefono: map['telefono'] as String? ?? '+51 987 654 321',
      pedidosCompletados: map['pedidosCompletados'] as int? ?? 0,
    );
  }

  Taller copyWith({
    String? id,
    String? nombre,
    String? ciudad,
    double? calificacion,
    int? totalCalificaciones,
    int? plazoDias,
    TablaPrecios? tablaPrecios,
    String? descripcion,
    List<TipoPrenda>? prendas,
    List<TecnicaConfeccion>? tecnicas,
    String? direccion,
    String? telefono,
    int? pedidosCompletados,
  }) {
    return Taller(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ciudad: ciudad ?? this.ciudad,
      calificacion: calificacion ?? this.calificacion,
      totalCalificaciones: totalCalificaciones ?? this.totalCalificaciones,
      plazoDias: plazoDias ?? this.plazoDias,
      tablaPrecios: tablaPrecios ?? this.tablaPrecios,
      descripcion: descripcion ?? this.descripcion,
      prendas: prendas ?? this.prendas,
      tecnicas: tecnicas ?? this.tecnicas,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      pedidosCompletados: pedidosCompletados ?? this.pedidosCompletados,
    );
  }
}

/// Distribución de tallas para el pedido
class DistribucionTallas {
  final Map<Talla, int> cantidades;

  const DistribucionTallas(this.cantidades);

  int get totalUnidades => cantidades.values.fold(0, (a, b) => a + b);

  DistribucionTallas copyWith(Talla talla, int cantidad) {
    final nuevo = Map<Talla, int>.from(cantidades);
    nuevo[talla] = cantidad;
    return DistribucionTallas(nuevo);
  }

  factory DistribucionTallas.inicial() => DistribucionTallas({
        for (final t in Talla.values) t: 0,
      });
}

/// Cotización de un taller para un pedido específico
class Cotizacion {
  final Taller taller;
  final double precioPorUnidad;
  final int totalUnidades;

  const Cotizacion({
    required this.taller,
    required this.precioPorUnidad,
    required this.totalUnidades,
  });

  double get total => precioPorUnidad * totalUnidades;

  Map<String, dynamic> toMap() {
    return {
      'taller': taller.toMap(),
      'precioPorUnidad': precioPorUnidad,
      'totalUnidades': totalUnidades,
    };
  }

  factory Cotizacion.fromMap(Map<String, dynamic> map) {
    return Cotizacion(
      taller: Taller.fromMap(Map<String, dynamic>.from(map['taller'] as Map? ?? {})),
      precioPorUnidad: (map['precioPorUnidad'] as num?)?.toDouble() ?? 40.0,
      totalUnidades: map['totalUnidades'] as int? ?? 1,
    );
  }
}

/// Estado del pedido en el ciclo de vida del taller y cliente
enum EstadoPedido {
  cotizado,
  confirmado,
  enProduccion,
  listo,
  entregado,
  rechazado;

  String get label {
    switch (this) {
      case EstadoPedido.cotizado:
        return 'Pendiente de aprobación';
      case EstadoPedido.confirmado:
        return 'Aprobado por el taller';
      case EstadoPedido.enProduccion:
        return 'En Producción';
      case EstadoPedido.listo:
        return 'Listo para entrega';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.rechazado:
        return 'Rechazado';
    }
  }
}

/// Ítem de pedido por talla
class PedidoItem {
  final Talla talla;
  final int cantidad;

  const PedidoItem({required this.talla, required this.cantidad});

  Map<String, dynamic> toMap() {
    return {
      'talla': talla.name,
      'cantidad': cantidad,
    };
  }

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    return PedidoItem(
      talla: Talla.values.firstWhere(
        (t) => t.name == map['talla'],
        orElse: () => Talla.M,
      ),
      cantidad: map['cantidad'] as int? ?? 1,
    );
  }
}

/// Pedido completo guardado en memoria y Firestore
class Pedido {
  final String id;
  final String clienteEmail;
  final String clienteNombre;
  final String notas;
  final DisenoPersonalizado diseno;
  final List<PedidoItem> items;
  final Cotizacion cotizacion;
  final EstadoPedido estado;
  final DateTime fechaCreacion;
  final bool calificado;

  const Pedido({
    required this.id,
    this.clienteEmail = 'usuario@sora.pe',
    this.clienteNombre = 'Usuario SORA',
    this.notas = '',
    required this.diseno,
    required this.items,
    required this.cotizacion,
    required this.estado,
    required this.fechaCreacion,
    this.calificado = false,
  });

  int get totalUnidades => items.fold(0, (a, b) => a + b.cantidad);

  Pedido copyWith({
    EstadoPedido? estado,
    String? clienteEmail,
    String? clienteNombre,
    String? notas,
    bool? calificado,
  }) => Pedido(
        id: id,
        clienteEmail: clienteEmail ?? this.clienteEmail,
        clienteNombre: clienteNombre ?? this.clienteNombre,
        notas: notas ?? this.notas,
        diseno: diseno,
        items: items,
        cotizacion: cotizacion,
        estado: estado ?? this.estado,
        fechaCreacion: fechaCreacion,
        calificado: calificado ?? this.calificado,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteEmail': clienteEmail,
      'clienteNombre': clienteNombre,
      'notas': notas,
      'diseno': diseno.toMap(),
      'items': items.map((i) => i.toMap()).toList(),
      'cotizacion': cotizacion.toMap(),
      'estado': estado.name,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'calificado': calificado,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Pedido(
      id: docId ?? (map['id'] as String? ?? 'PED-000'),
      clienteEmail: map['clienteEmail'] as String? ?? 'usuario@sora.pe',
      clienteNombre: map['clienteNombre'] as String? ?? 'Usuario SORA',
      notas: map['notas'] as String? ?? '',
      diseno: map['diseno'] != null
          ? DisenoPersonalizado.fromMap(Map<String, dynamic>.from(map['diseno'] as Map))
          : DisenoPersonalizado.inicial(),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => PedidoItem.fromMap(Map<String, dynamic>.from(item as Map)))
              .toList() ??
          const [],
      cotizacion: map['cotizacion'] != null
          ? Cotizacion.fromMap(Map<String, dynamic>.from(map['cotizacion'] as Map))
          : Cotizacion(
              taller: const Taller(
                id: 'taller_01',
                nombre: 'Taller',
                ciudad: 'Lima',
                calificacion: 0.0,
                totalCalificaciones: 0,
                plazoDias: 10,
                tablaPrecios: TablaPrecios(
                  precioBase: 40,
                  multiplicadorTela: 1,
                  multiplicadorEstampado: 3.5,
                  costoCierreMetal: 5,
                  costoCierrePlastico: 3,
                  costoBolsilloLateral: 4,
                  costoBolsilloPecho: 3,
                  costoBolsilloInterno: 4.5,
                ),
                descripcion: '',
                prendas: [],
                tecnicas: [],
              ),
              precioPorUnidad: 40,
              totalUnidades: 1,
            ),
      estado: EstadoPedido.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoPedido.cotizado,
      ),
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.tryParse(map['fechaCreacion'].toString()) ?? DateTime.now()
          : DateTime.now(),
      calificado: map['calificado'] as bool? ?? false,
    );
  }
}
