import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_model.dart';
import '../services/inventory_service.dart';

/// Manages inventory state, stock adjustments and low-stock alerts.
class InventoryProvider extends ChangeNotifier {
  final InventoryService _service = InventoryService();
  final _uuid = const Uuid();

  List<InventoryModel> _items = [];
  List<InventoryModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<InventoryModel> get items => _filtered;
  List<InventoryModel> get allItems => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Items where quantity <= threshold
  List<InventoryModel> get lowStockItems =>
      _items.where((i) => i.isLowStock).toList();

  int get lowStockCount => lowStockItems.length;

  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _service.getAll();
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

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_items);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _items
          .where((i) =>
              i.name.toLowerCase().contains(q) ||
              (i.category?.toLowerCase().contains(q) ?? false))
          .toList();
    }
  }

  Future<bool> addItem({
    required String name,
    required String unit,
    required double quantity,
    required double lowStockThreshold,
    double? pricePerUnit,
    String? category,
  }) async {
    try {
      final item = InventoryModel(
        id: 'I${_uuid.v4().substring(0, 8).toUpperCase()}',
        name: name,
        unit: unit,
        quantity: quantity,
        lowStockThreshold: lowStockThreshold,
        pricePerUnit: pricePerUnit,
        category: category,
        lastUpdated: DateTime.now().toIso8601String().split('T').first,
      );
      await _service.add(item);
      await loadInventory();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItem(InventoryModel updated) async {
    try {
      await _service.update(updated);
      await loadInventory();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _service.delete(id);
      await loadInventory();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> reduceStock(String id, double amount) async {
    await _service.reduceStock(id, amount);
    await loadInventory();
  }

  Future<void> addStock(String id, double amount) async {
    await _service.addStock(id, amount);
    await loadInventory();
  }
}
