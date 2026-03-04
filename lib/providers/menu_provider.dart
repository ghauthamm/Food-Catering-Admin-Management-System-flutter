import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';

/// Manages day-wise menu state and CRUD operations.
class MenuProvider extends ChangeNotifier {
  final MenuService _service = MenuService();
  final _uuid = const Uuid();

  List<DayMenu> _menus = [];
  List<DayMenu> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _selectedDay = 'all';

  List<DayMenu> get menus => _filtered;
  List<DayMenu> get allMenus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDay => _selectedDay;

  Future<void> loadMenus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _menus = await _service.getAll();
      _menus.sort((a, b) {
        final dayOrder = weekDays.indexOf(a.day).compareTo(weekDays.indexOf(b.day));
        if (dayOrder != 0) return dayOrder;
        return a.mealType.compareTo(b.mealType);
      });
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDayFilter(String day) {
    _selectedDay = day;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedDay == 'all') {
      _filtered = List<DayMenu>.from(_menus);
    } else {
      _filtered = _menus.where((m) => m.day == _selectedDay).toList();
    }
  }

  Future<bool> addMenu({
    required String day,
    required String mealType,
    required List<MenuItem> items,
    bool isActive = true,
  }) async {
    try {
      final menu = DayMenu(
        id: 'M${_uuid.v4().substring(0, 8).toUpperCase()}',
        day: day,
        mealType: mealType,
        items: items,
        isActive: isActive,
        lastUpdated: DateTime.now().toIso8601String().split('T').first,
      );
      await _service.add(menu);
      await loadMenus();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMenu(DayMenu updated) async {
    try {
      await _service.update(updated);
      await loadMenus();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMenu(String id) async {
    try {
      await _service.delete(id);
      await loadMenus();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleActive(String id) async {
    try {
      final menu = _menus.firstWhere((m) => m.id == id);
      await _service.update(menu.copyWith(isActive: !menu.isActive));
      await loadMenus();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get menu items for a specific day and meal type (used in order creation).
  List<MenuItem> getMenuItemsForDayAndMeal(String day, String mealType) {
    try {
      final menu = _menus.firstWhere(
        (m) => m.day == day && m.mealType == mealType && m.isActive,
      );
      return menu.items;
    } catch (_) {
      return [];
    }
  }

  /// Get all active menus for a specific day.
  List<DayMenu> getMenusForDay(String day) {
    return _menus.where((m) => m.day == day && m.isActive).toList();
  }
}
