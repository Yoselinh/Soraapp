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
}

/// Modelo de un taller de confección
class Taller {
  final String id;
  final String nombre;
  final String ciudad;
  final double calificacion; // 1.0 - 5.0
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
    required this.calificacion,
    required this.plazoDias,
    required this.tablaPrecios,
    required this.descripcion,
    required this.prendas,
    required this.tecnicas,
    this.direccion = 'Zona Industrial Textil',
    this.telefono = '+51 987 654 321',
    this.pedidosCompletados = 145,
  });

  bool confecciona(TipoPrenda prenda) => prendas.contains(prenda);
  bool tieneTecnica(TecnicaConfeccion tecnica) => tecnicas.contains(tecnica);
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
}

/// Estado del pedido
enum EstadoPedido { cotizado, confirmado }

/// Ítem de pedido por talla
class PedidoItem {
  final Talla talla;
  final int cantidad;

  const PedidoItem({required this.talla, required this.cantidad});
}

/// Pedido completo guardado en memoria
class Pedido {
  final String id;
  final DisenoPersonalizado diseno;
  final List<PedidoItem> items;
  final Cotizacion cotizacion;
  final EstadoPedido estado;
  final DateTime fechaCreacion;

  const Pedido({
    required this.id,
    required this.diseno,
    required this.items,
    required this.cotizacion,
    required this.estado,
    required this.fechaCreacion,
  });

  int get totalUnidades => items.fold(0, (a, b) => a + b.cantidad);

  Pedido copyWith({EstadoPedido? estado}) => Pedido(
        id: id,
        diseno: diseno,
        items: items,
        cotizacion: cotizacion,
        estado: estado ?? this.estado,
        fechaCreacion: fechaCreacion,
      );
}
