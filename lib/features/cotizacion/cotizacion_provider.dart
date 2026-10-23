import 'package:flutter/foundation.dart';
import 'package:sora_app/models/taller.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/data/talleres_repository.dart';

enum OrdenCotizacion { precio, plazo, calificacion }

/// Provider que gestiona la cotización: distribución de tallas y lista de cotizaciones
class CotizacionProvider extends ChangeNotifier {
  DistribucionTallas _distribucion = DistribucionTallas.inicial();
  List<Cotizacion> _cotizaciones = [];
  OrdenCotizacion _orden = OrdenCotizacion.precio;

  DistribucionTallas get distribucion => _distribucion;
  OrdenCotizacion get orden => _orden;

  List<Cotizacion> get cotizaciones {
    final lista = List<Cotizacion>.from(_cotizaciones);
    switch (_orden) {
      case OrdenCotizacion.precio:
        lista.sort((a, b) => a.total.compareTo(b.total));
      case OrdenCotizacion.plazo:
        lista.sort((a, b) => a.taller.plazoDias.compareTo(b.taller.plazoDias));
      case OrdenCotizacion.calificacion:
        lista.sort((a, b) => b.taller.calificacion.compareTo(a.taller.calificacion));
    }
    return lista;
  }

  void actualizarCantidad(Talla talla, int cantidad) {
    _distribucion = _distribucion.copyWith(talla, cantidad.clamp(0, 999));
    notifyListeners();
  }

  void calcularCotizaciones(DisenoPersonalizado diseno) {
    final total = _distribucion.totalUnidades;
    if (total == 0) return;

    final talleresDisponibles = TalleresRepository.instance.talleres
        .where((taller) => taller.confecciona(diseno.prenda))
        .toList();

    _cotizaciones = talleresDisponibles.map((taller) {
      final ppu = taller.tablaPrecios.calcularPorUnidad(diseno);
      return Cotizacion(
        taller: taller,
        precioPorUnidad: ppu,
        totalUnidades: total,
      );
    }).toList();
    notifyListeners();
  }

  /// Permite cotizar directamente con un taller elegido
  void cotizarConTallerEspecifico(Taller taller, DisenoPersonalizado diseno) {
    if (_distribucion.totalUnidades == 0) {
      _distribucion = _distribucion.copyWith(Talla.M, 10);
    }
    final total = _distribucion.totalUnidades;
    final ppu = taller.tablaPrecios.calcularPorUnidad(diseno);
    _cotizaciones = [
      Cotizacion(
        taller: taller,
        precioPorUnidad: ppu,
        totalUnidades: total,
      ),
    ];
    notifyListeners();
  }

  void cambiarOrden(OrdenCotizacion nuevo) {
    _orden = nuevo;
    notifyListeners();
  }

  void reiniciar() {
    _distribucion = DistribucionTallas.inicial();
    _cotizaciones = [];
    _orden = OrdenCotizacion.precio;
    notifyListeners();
  }
}
