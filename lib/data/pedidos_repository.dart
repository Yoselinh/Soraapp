import 'package:flutter/foundation.dart';
import 'package:sora_app/models/taller.dart';

/// Repositorio en memoria para pedidos
class PedidosRepository extends ChangeNotifier {
  PedidosRepository._();
  static final PedidosRepository instance = PedidosRepository._();

  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  void agregarPedido(Pedido pedido) {
    _pedidos.add(pedido);
    notifyListeners();
  }

  void confirmarPedido(String pedidoId) {
    final index = _pedidos.indexWhere((p) => p.id == pedidoId);
    if (index != -1) {
      _pedidos[index] = _pedidos[index].copyWith(estado: EstadoPedido.confirmado);
      notifyListeners();
    }
  }
}
