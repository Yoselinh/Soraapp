import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sora_app/data/talleres_repository.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/models/taller.dart';

/// Roles de usuario soportados en la aplicación
enum RolUsuario {
  cliente,
  taller;

  String get label => this == RolUsuario.cliente ? 'Cliente' : 'Taller';
}

/// Provider que gestiona la sesión, autenticación y el rol del usuario (Cliente vs Taller)
/// Conectado con Cloud Firestore para persistencia de usuarios.
class AuthProvider extends ChangeNotifier {
  bool _estaAutenticado = false;
  RolUsuario _rol = RolUsuario.cliente;
  String _tallerActivoId = '';

  String _nombreUsuario = 'Usuario SORA';
  String _emailUsuario = 'usuario@sora.pe';

  bool get estaAutenticado => _estaAutenticado;
  RolUsuario get rol => _rol;
  bool get esTaller => _rol == RolUsuario.taller;
  bool get esCliente => _rol == RolUsuario.cliente;

  String get nombreUsuario => esTaller ? tallerActivo.nombre : _nombreUsuario;
  String get emailUsuario => esTaller ? 'contacto@${tallerActivo.nombre.toLowerCase().replaceAll(' ', '')}.pe' : _emailUsuario;

  String get tallerActivoId => _tallerActivoId;

  Taller get tallerActivo {
    final talleres = TalleresRepository.instance.talleres;
    if (_tallerActivoId.isNotEmpty) {
      final encontrado = talleres.where((t) => t.id == _tallerActivoId);
      if (encontrado.isNotEmpty) return encontrado.first;
    }
    if (talleres.isNotEmpty) return talleres.first;

    return Taller(
      id: _tallerActivoId.isNotEmpty ? _tallerActivoId : 'taller_nuevo',
      nombre: _nombreUsuario.isNotEmpty && _nombreUsuario != 'Usuario SORA' ? _nombreUsuario : 'Mi Taller Textil',
      ciudad: 'Lima',
      calificacion: 0.0,
      totalCalificaciones: 0,
      plazoDias: 10,
      tablaPrecios: const TablaPrecios(
        precioBase: 40.0,
        multiplicadorTela: 1.0,
        multiplicadorEstampado: 3.5,
        costoCierreMetal: 5.0,
        costoCierrePlastico: 3.0,
        costoBolsilloLateral: 4.0,
        costoBolsilloPecho: 3.0,
        costoBolsilloInterno: 4.5,
      ),
      descripcion: 'Taller de confección textil registrado en SORA.',
      prendas: TipoPrenda.values,
      tecnicas: TecnicaConfeccion.values,
    );
  }

  List<Taller> get talleresDisponibles => TalleresRepository.instance.talleres;

  void cambiarRol(RolUsuario nuevoRol) {
    if (_rol != nuevoRol) {
      _rol = nuevoRol;
      notifyListeners();
    }
  }

  void alternarRol() {
    _rol = _rol == RolUsuario.cliente ? RolUsuario.taller : RolUsuario.cliente;
    notifyListeners();
  }

  void seleccionarTaller(String id) {
    if (_tallerActivoId != id) {
      _tallerActivoId = id;
      notifyListeners();
    }
  }

  void actualizarDatosUsuario({String? nombre, String? email}) {
    if (nombre != null) _nombreUsuario = nombre;
    if (email != null) _emailUsuario = email;
    notifyListeners();
  }

  /// Inicia sesión con rol y recupera datos de Firestore
  Future<void> iniciarSesion({
    required String email,
    required String password,
    required RolUsuario rol,
  }) async {
    _emailUsuario = email.trim();
    _rol = rol;
    _estaAutenticado = true;

    final docId = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    _tallerActivoId = 'taller_$docId';

    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nombreUsuario = data['nombre'] as String? ?? _nombreUsuario;
        if (data['tallerId'] != null) {
          _tallerActivoId = data['tallerId'] as String;
        }
      }
    } catch (e) {
      debugPrint('Aviso al recuperar usuario de Firestore: $e');
    }

    notifyListeners();
  }

  /// Registra un nuevo usuario en la app y crea su taller en Firestore si es rol taller
  Future<void> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    required RolUsuario rol,
    String? ciudad,
    String? direccion,
    String? telefono,
  }) async {
    _nombreUsuario = nombre.trim();
    _emailUsuario = email.trim();
    _rol = rol;
    _estaAutenticado = true;

    final docId = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

    if (rol == RolUsuario.taller) {
      _tallerActivoId = 'taller_$docId';
      final nuevoTaller = Taller(
        id: _tallerActivoId,
        nombre: _nombreUsuario,
        ciudad: (ciudad != null && ciudad.trim().isNotEmpty) ? ciudad.trim() : 'Lima',
        direccion: (direccion != null && direccion.trim().isNotEmpty) ? direccion.trim() : 'Local Principal',
        telefono: (telefono != null && telefono.trim().isNotEmpty) ? telefono.trim() : '+51 987 654 321',
        calificacion: 0.0,
        totalCalificaciones: 0,
        plazoDias: 10,
        pedidosCompletados: 0,
        descripcion: 'Taller de confección textil registrado en SORA.',
        prendas: TipoPrenda.values,
        tecnicas: TecnicaConfeccion.values,
        tablaPrecios: const TablaPrecios(
          precioBase: 40.0,
          multiplicadorTela: 1.0,
          multiplicadorEstampado: 3.5,
          costoCierreMetal: 5.0,
          costoCierrePlastico: 3.0,
          costoBolsilloLateral: 4.0,
          costoBolsilloPecho: 3.0,
          costoBolsilloInterno: 4.5,
        ),
      );
      await TalleresRepository.instance.actualizarTaller(nuevoTaller);
    }

    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(docId).set({
        'nombre': _nombreUsuario,
        'email': _emailUsuario,
        'rol': _rol.name,
        'tallerId': esTaller ? _tallerActivoId : null,
        'fechaRegistro': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Aviso al registrar usuario en Firestore: $e');
    }
  }

  /// Cierra la sesión activa
  void cerrarSesion() {
    _estaAutenticado = false;
    _nombreUsuario = 'Usuario SORA';
    _emailUsuario = 'usuario@sora.pe';
    _rol = RolUsuario.cliente;
    notifyListeners();
  }
}
