import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

/// Manages purchase/expense state and CRUD operations.
class PurchaseProvider extends ChangeNotifier {
  final PurchaseService _service = PurchaseService();
  final _uuid = const Uuid();

  List<PurchaseModel> _purchases = [];
  List<PurchaseModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<PurchaseModel> get purchases => _filtered;
  List<PurchaseModel> get allPurchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPurchases() async {
    _isLoading = true;
    notifyListeners();
    try {
      _purchases = await _service.getAll();
      _purchases.sort((a, b) => b.date.compareTo(a.date));
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
      _filtered = List.from(_purchases);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _purchases
          .where((p) =>
              p.itemName.toLowerCase().contains(q) ||
              p.vendorName.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<bool> addPurchase({
    required String vendorName,
    required String itemName,
    required double quantity,
    required String unit,
    required double price,
    required bool gstIncluded,
    double? gstPercent,
    required String date,
    String? category,
    String? notes,
  }) async {
    try {
      final purchase = PurchaseModel(
        id: 'P${_uuid.v4().substring(0, 8).toUpperCase()}',
        vendorName: vendorName,
        itemName: itemName,
        quantity: quantity,
        unit: unit,
        price: price,
        gstIncluded: gstIncluded,
        gstPercent: gstPercent,
        date: date,
        category: category,
        notes: notes,
      );
      await _service.add(purchase);
      await loadPurchases();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePurchase(PurchaseModel updated) async {
    try {
      await _service.update(updated);
      await loadPurchases();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePurchase(String id) async {
    try {
      await _service.delete(id);
      await loadPurchases();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Total expense this month
  double get monthExpense {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _purchases
        .where((p) => p.date.startsWith(month))
        .fold(0.0, (sum, p) => sum + p.totalPrice);
  }
}
