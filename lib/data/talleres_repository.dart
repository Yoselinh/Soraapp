import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sora_app/models/taller.dart';

/// Repositorio de talleres con sincronización en tiempo real con Cloud Firestore
class TalleresRepository extends ChangeNotifier {
  TalleresRepository._() {
    _iniciarSincronizacionFirestore();
  }
  static final TalleresRepository instance = TalleresRepository._();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSubscription;

  final List<Taller> _talleres = [];

  List<Taller> get talleres => List.unmodifiable(_talleres);

  // Lista de IDs o nombres de talleres estáticos/mock antiguos que deben limpiarse de Firestore
  static const _idsMockAEliminar = {
    'taller_01',
    'taller_02',
    'taller_03',
    'taller_04',
    'taller_05',
    'taller_06',
  };

  static const _nombresMockAEliminar = {
    'Creaciones & Moda Gamarra',
    'Taller Textil del Sur',
    'Bordados y Estilismos Lima',
    'Confecciones San Martín',
    'Tejidos & Confección Norte',
    'Estampados & Diseños Cusco',
  };

  void _iniciarSincronizacionFirestore() {
    try {
      final firestore = FirebaseFirestore.instance;
      _firestoreSubscription = firestore
          .collection('talleres')
          .snapshots()
          .listen((snapshot) {
        _talleres.clear();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final nombre = data['nombre'] as String? ?? '';

          // Si es un documento mock heredado, eliminarlo de la base de datos Firestore y no mostrarlo
          if (_idsMockAEliminar.contains(doc.id) || _nombresMockAEliminar.contains(nombre)) {
            firestore.collection('talleres').doc(doc.id).delete().catchError((e) {
              debugPrint('Aviso al purgar taller mock ${doc.id}: $e');
            });
            continue;
          }

          try {
            final taller = Taller.fromMap(data, doc.id);
            _talleres.add(taller);
          } catch (e) {
            debugPrint('Error al deserializar taller ${doc.id}: $e');
          }
        }
        notifyListeners();
      }, onError: (error) {
        debugPrint('Aviso Firestore talleres: $error');
      });
    } catch (e) {
      debugPrint('Aviso al conectar Firestore talleres: $e');
    }
  }

  /// Califica un taller con una nueva puntuación del cliente (1.0 a 5.0) y actualiza Firestore
  Future<void> calificarTaller(String tallerId, double puntuacion) async {
    final index = _talleres.indexWhere((t) => t.id == tallerId);
    if (index == -1) return;

    final tallerActual = _talleres[index];
    final totalActual = tallerActual.totalCalificaciones;
    final califActual = tallerActual.calificacion;

    final nuevoTotal = totalActual + 1;
    final nuevaCalificacion = totalActual == 0
        ? puntuacion
        : double.parse(((califActual * totalActual + puntuacion) / nuevoTotal).toStringAsFixed(1));

    final tallerActualizado = tallerActual.copyWith(
      calificacion: nuevaCalificacion,
      totalCalificaciones: nuevoTotal,
    );

    _talleres[index] = tallerActualizado;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('talleres').doc(tallerId).update({
        'calificacion': nuevaCalificacion,
        'totalCalificaciones': nuevoTotal,
      });
    } catch (e) {
      debugPrint('Error al guardar calificación en Firestore: $e');
    }
  }

  Future<void> actualizarTaller(Taller tallerActualizado) async {
    final index = _talleres.indexWhere((t) => t.id == tallerActualizado.id);
    if (index != -1) {
      _talleres[index] = tallerActualizado;
    } else {
      _talleres.add(tallerActualizado);
    }
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('talleres')
          .doc(tallerActualizado.id)
          .set(tallerActualizado.toMap());
    } catch (e) {
      debugPrint('Error al actualizar taller en Firestore: $e');
    }
  }

  Future<void> eliminarTaller(String tallerId) async {
    _talleres.removeWhere((t) => t.id == tallerId);
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('talleres').doc(tallerId).delete();
    } catch (e) {
      debugPrint('Error al eliminar taller de Firestore: $e');
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
