import '../models/purchase_model.dart';
import 'storage_service.dart';

/// CRUD service for purchase/expense data stored in purchases.json
class PurchaseService {
  final StorageService _storage = StorageService.instance;

  Future<List<PurchaseModel>> getAll() async {
    final list = await _storage.readList(StorageFiles.purchases);
    return list.map((e) => PurchaseModel.fromJson(e)).toList();
  }

  Future<void> add(PurchaseModel purchase) async {
    final purchases = await getAll();
    purchases.add(purchase);
    await _save(purchases);
  }

  Future<void> update(PurchaseModel updated) async {
    final purchases = await getAll();
    final index = purchases.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      purchases[index] = updated;
      await _save(purchases);
    }
  }

  Future<void> delete(String id) async {
    final purchases = await getAll();
    purchases.removeWhere((p) => p.id == id);
    await _save(purchases);
  }

  /// Returns purchases for a given month (format: 'YYYY-MM')
  Future<List<PurchaseModel>> getByMonth(String month) async {
    final purchases = await getAll();
    return purchases.where((p) => p.date.startsWith(month)).toList();
  }

  /// Total expense for a given month
  Future<double> monthlyExpense(String month) async {
    final purchases = await getByMonth(month);
    return purchases.fold<double>(0.0, (sum, p) => sum + p.totalPrice);
  }

  Future<void> _save(List<PurchaseModel> purchases) async {
    await _storage.writeList(
      StorageFiles.purchases,
      purchases.map((p) => p.toJson()).toList(),
    );
  }
}
