import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sora_app/data/talleres_repository.dart';
import 'package:sora_app/models/diseno_personalizado.dart';
import 'package:sora_app/models/taller.dart';

/// Repositorio de pedidos con sincronización en tiempo real con Cloud Firestore
class PedidosRepository extends ChangeNotifier {
  PedidosRepository._() {
    _iniciarSincronizacionFirestore();
  }
  static final PedidosRepository instance = PedidosRepository._();

  final List<Pedido> _pedidos = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSubscription;

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  void _iniciarSincronizacionFirestore() {
    try {
      final firestore = FirebaseFirestore.instance;
      _firestoreSubscription = firestore
          .collection('pedidos')
          .snapshots()
          .listen((snapshot) {
        _pedidos.clear();
        for (final doc in snapshot.docs) {
          try {
            final pedido = Pedido.fromMap(doc.data(), doc.id);
            _pedidos.add(pedido);
          } catch (e) {
            debugPrint('Error al deserializar pedido ${doc.id}: $e');
          }
        }
        _pedidos.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
        notifyListeners();
      }, onError: (error) {
        debugPrint('Aviso Firestore pedidos: $error');
      });
    } catch (e) {
      debugPrint('Aviso al conectar Firestore: $e');
    }
  }

  Future<void> agregarPedido(Pedido pedido) async {
    _pedidos.removeWhere((p) => p.id == pedido.id);
    _pedidos.insert(0, pedido);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedido.id)
          .set(pedido.toMap());
    } catch (e) {
      debugPrint('Error al guardar pedido en Firestore: $e');
    }
  }

  void confirmarPedido(String pedidoId) {
    actualizarEstado(pedidoId, EstadoPedido.confirmado);
  }

  Future<void> actualizarEstado(String pedidoId, EstadoPedido nuevoEstado) async {
    final index = _pedidos.indexWhere((p) => p.id == pedidoId);
    if (index != -1) {
      _pedidos[index] = _pedidos[index].copyWith(estado: nuevoEstado);
      notifyListeners();
    }

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({'estado': nuevoEstado.name});
    } catch (e) {
      debugPrint('Error al actualizar estado en Firestore: $e');
    }
  }

  void rechazarPedido(String pedidoId) {
    actualizarEstado(pedidoId, EstadoPedido.rechazado);
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  // ── Filtros por Cliente ────────────────────────────────────────────────────

  List<Pedido> pedidosPorCliente(String email) {
    if (email.trim().isEmpty) return const [];
    final emailNorm = email.trim().toLowerCase();
    return _pedidos
        .where((p) => p.clienteEmail.trim().toLowerCase() == emailNorm)
        .toList();
  }

  // ── Filtros por Taller ─────────────────────────────────────────────────────

  List<Pedido> pedidosPorTaller(String tallerId) {
    return _pedidos.where((p) => p.cotizacion.taller.id == tallerId).toList();
  }

  List<Pedido> solicitudesPendientesPorTaller(String tallerId) {
    return _pedidos
        .where((p) =>
            p.cotizacion.taller.id == tallerId &&
            p.estado == EstadoPedido.cotizado)
        .toList();
  }

  List<Pedido> enProduccionPorTaller(String tallerId) {
    return _pedidos
        .where((p) =>
            p.cotizacion.taller.id == tallerId &&
            (p.estado == EstadoPedido.confirmado ||
                p.estado == EstadoPedido.enProduccion))
        .toList();
  }

  List<Pedido> listosPorTaller(String tallerId) {
    return _pedidos
        .where((p) =>
            p.cotizacion.taller.id == tallerId &&
            p.estado == EstadoPedido.listo)
        .toList();
  }

  List<Pedido> completadosPorTaller(String tallerId) {
    return _pedidos
        .where((p) =>
            p.cotizacion.taller.id == tallerId &&
            p.estado == EstadoPedido.entregado)
        .toList();
  }

  // ── Métricas del Taller ────────────────────────────────────────────────────

  double ingresosTotalesTaller(String tallerId) {
    return _pedidos
        .where((p) =>
            p.cotizacion.taller.id == tallerId &&
            p.estado != EstadoPedido.rechazado &&
            p.estado != EstadoPedido.cotizado)
        .fold(0.0, (acc, p) => acc + p.cotizacion.total);
  }

  // ── Calificación por Cliente ───────────────────────────────────────────────

  Future<void> calificarPedido({
    required String pedidoId,
    required String tallerId,
    required double puntuacion,
  }) async {
    // 1. Calificar el taller en TalleresRepository y Firestore
    await TalleresRepository.instance.calificarTaller(tallerId, puntuacion);

    // 2. Marcar el pedido como calificado
    final index = _pedidos.indexWhere((p) => p.id == pedidoId);
    if (index != -1) {
      _pedidos[index] = _pedidos[index].copyWith(calificado: true);
      notifyListeners();
    }

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({'calificado': true});
    } catch (e) {
      debugPrint('Error al marcar pedido como calificado en Firestore: $e');
    }
  }
}
