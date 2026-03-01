import '../models/inventory_model.dart';
import 'storage_service.dart';

/// CRUD service for inventory data stored in inventory.json
class InventoryService {
  final StorageService _storage = StorageService.instance;

  Future<List<InventoryModel>> getAll() async {
    final list = await _storage.readList(StorageFiles.inventory);
    return list.map((e) => InventoryModel.fromJson(e)).toList();
  }

  Future<InventoryModel?> getById(String id) async {
    final items = await getAll();
    try {
      return items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(InventoryModel item) async {
    final items = await getAll();
    items.add(item);
    await _save(items);
  }

  Future<void> update(InventoryModel updated) async {
    final items = await getAll();
    final index = items.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      items[index] = updated;
      await _save(items);
    }
  }

  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((i) => i.id == id);
    await _save(items);
  }

  /// Reduces stock quantity by [amount]. Clamps to 0.
  Future<void> reduceStock(String id, double amount) async {
    final item = await getById(id);
    if (item == null) return;
    final newQty = (item.quantity - amount).clamp(0.0, double.infinity);
    await update(item.copyWith(
      quantity: newQty,
      lastUpdated: DateTime.now().toIso8601String().split('T').first,
    ));
  }

  /// Adds stock quantity by [amount].
  Future<void> addStock(String id, double amount) async {
    final item = await getById(id);
    if (item == null) return;
    await update(item.copyWith(
      quantity: item.quantity + amount,
      lastUpdated: DateTime.now().toIso8601String().split('T').first,
    ));
  }

  /// Returns all items with stock at or below their threshold.
  Future<List<InventoryModel>> getLowStockItems() async {
    final items = await getAll();
    return items.where((i) => i.isLowStock).toList();
  }

  Future<void> _save(List<InventoryModel> items) async {
    await _storage.writeList(
      StorageFiles.inventory,
      items.map((i) => i.toJson()).toList(),
    );
  }
}
