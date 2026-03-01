import '../models/order_model.dart';
import 'storage_service.dart';

/// CRUD service for order data stored in orders.json
class OrderService {
  final StorageService _storage = StorageService.instance;

  Future<List<OrderModel>> getAll() async {
    final list = await _storage.readList(StorageFiles.orders);
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel?> getById(String id) async {
    final orders = await getAll();
    try {
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(OrderModel order) async {
    final orders = await getAll();
    orders.add(order);
    await _save(orders);
  }

  Future<void> update(OrderModel updated) async {
    final orders = await getAll();
    final index = orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) {
      orders[index] = updated;
      await _save(orders);
    }
  }

  Future<void> delete(String id) async {
    final orders = await getAll();
    orders.removeWhere((o) => o.id == id);
    await _save(orders);
  }

  /// Returns orders filtered by date (format: 'YYYY-MM-DD')
  Future<List<OrderModel>> getByDate(String date) async {
    final orders = await getAll();
    return orders.where((o) => o.date == date).toList();
  }

  /// Returns orders for a given month (format: 'YYYY-MM')
  Future<List<OrderModel>> getByMonth(String month) async {
    final orders = await getAll();
    return orders.where((o) => o.date.startsWith(month)).toList();
  }

  /// Returns total revenue for a given month
  Future<double> monthlyRevenue(String month) async {
    final orders = await getByMonth(month);
    return orders
        .where((o) => o.status != 'cancelled')
        .fold<double>(0.0, (sum, o) => sum + o.totalAmount);
  }

  Future<void> _save(List<OrderModel> orders) async {
    await _storage.writeList(
      StorageFiles.orders,
      orders.map((o) => o.toJson()).toList(),
    );
  }
}
