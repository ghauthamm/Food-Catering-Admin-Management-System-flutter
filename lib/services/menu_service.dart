import '../models/menu_model.dart';
import 'storage_service.dart';

/// CRUD service for day-wise menu data stored in menus.json
class MenuService {
  final StorageService _storage = StorageService.instance;

  static const String _filename = 'menus.json';

  Future<List<DayMenu>> getAll() async {
    final list = await _storage.readList(_filename);
    return list.map((e) => DayMenu.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DayMenu?> getById(String id) async {
    final menus = await getAll();
    try {
      return menus.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all menus for a specific day (e.g. 'Monday')
  Future<List<DayMenu>> getByDay(String day) async {
    final menus = await getAll();
    return menus.where((m) => m.day == day && m.isActive).toList();
  }

  /// Returns menus for a specific day + meal type
  Future<DayMenu?> getByDayAndMeal(String day, String mealType) async {
    final menus = await getAll();
    try {
      return menus.firstWhere(
        (m) => m.day == day && m.mealType == mealType && m.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> add(DayMenu menu) async {
    final menus = await getAll();
    menus.add(menu);
    await _save(menus);
  }

  Future<void> update(DayMenu updated) async {
    final menus = await getAll();
    final index = menus.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      menus[index] = updated;
      await _save(menus);
    }
  }

  Future<void> delete(String id) async {
    final menus = await getAll();
    menus.removeWhere((m) => m.id == id);
    await _save(menus);
  }

  Future<void> _save(List<DayMenu> menus) async {
    await _storage.writeList(
      _filename,
      menus.map((m) => m.toJson()).toList(),
    );
  }
}
