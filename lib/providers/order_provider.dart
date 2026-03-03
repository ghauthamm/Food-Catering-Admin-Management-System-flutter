import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

/// Manages order list state and CRUD operations.
class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService();
  final _uuid = const Uuid();

  List<OrderModel> _orders = [];
  List<OrderModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _statusFilter = 'all';

  List<OrderModel> get orders => _filtered;
  List<OrderModel> get allOrders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get statusFilter => _statusFilter;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _service.getAll();
      // Sort by date descending
      _orders.sort((a, b) => b.date.compareTo(a.date));
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var list = List<OrderModel>.from(_orders);
    if (_statusFilter != 'all') {
      list = list.where((o) => o.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((o) =>
              o.clientName.toLowerCase().contains(q) ||
              o.id.toLowerCase().contains(q))
          .toList();
    }
    _filtered = list;
  }

  Future<bool> addOrder({
    required String clientId,
    required String clientName,
    required String mealType,
    required List<OrderItem> items,
    required String date,
    String? notes,
  }) async {
    try {
      final total = items.fold(0.0, (sum, i) => sum + i.total);
      final order = OrderModel(
        id: 'O${_uuid.v4().substring(0, 8).toUpperCase()}',
        clientId: clientId,
        clientName: clientName,
        mealType: mealType,
        items: items,
        totalAmount: total,
        date: date,
        notes: notes,
      );
      await _service.add(order);
      await loadOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateOrder(OrderModel updated) async {
    try {
      await _service.update(updated);
      await loadOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    final order = _orders.firstWhere((o) => o.id == id,
        orElse: () => throw Exception('Not found'));
    return updateOrder(order.copyWith(status: status));
  }

  Future<bool> deleteOrder(String id) async {
    try {
      await _service.delete(id);
      await loadOrders();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Today's total revenue (delivered orders only)
  double get todayRevenue {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _orders
        .where((o) => o.date == today && o.status == 'delivered')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  /// Current month total revenue
  double get monthRevenue {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _orders
        .where((o) => o.date.startsWith(month) && o.status != 'cancelled')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }
}
