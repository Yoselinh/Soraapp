import 'package:flutter/foundation.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/models/taller.dart';

/// Provider que maneja el estado del diseñador paso a paso
class DisenadorProvider extends ChangeNotifier {
  DisenoPersonalizado _diseno = DisenoPersonalizado.inicial();
  int _pasoActual = 0; // 0..5
  static const int totalPasos = 6;
  Taller? _tallerPreseleccionado;

  DisenoPersonalizado get diseno => _diseno;
  int get pasoActual => _pasoActual;
  Taller? get tallerPreseleccionado => _tallerPreseleccionado;
  bool get tieneTallerPreseleccionado => _tallerPreseleccionado != null;

  bool get puedeAvanzar => true;

  void preseleccionarTaller(Taller taller) {
    _tallerPreseleccionado = taller;
    if (!taller.confecciona(_diseno.prenda)) {
      _diseno = _diseno.copyWith(prenda: taller.prendas.first);
    }
    _pasoActual = 0;
    notifyListeners();
  }

  void limpiarTallerPreseleccionado() {
    _tallerPreseleccionado = null;
    notifyListeners();
  }

  void actualizarDiseno(DisenoPersonalizado nuevo) {
    _diseno = nuevo;
    notifyListeners();
  }

  void avanzarPaso() {
    if (_pasoActual < totalPasos - 1) {
      _pasoActual++;
      notifyListeners();
    }
  }

  void retrocederPaso() {
    if (_pasoActual > 0) {
      _pasoActual--;
      notifyListeners();
    }
  }

  void irAPaso(int paso) {
    assert(paso >= 0 && paso < totalPasos);
    _pasoActual = paso;
    notifyListeners();
  }

  void reiniciar() {
    _diseno = DisenoPersonalizado.inicial();
    if (_tallerPreseleccionado != null && !_tallerPreseleccionado!.confecciona(_diseno.prenda)) {
      _diseno = _diseno.copyWith(prenda: _tallerPreseleccionado!.prendas.first);
    }
    _pasoActual = 0;
    notifyListeners();
  }
}
