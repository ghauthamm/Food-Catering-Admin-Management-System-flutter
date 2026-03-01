import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

/// Manages employee state, attendance and salary operations.
class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service = EmployeeService();
  final _uuid = const Uuid();

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filtered = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<EmployeeModel> get employees => _filtered;
  List<EmployeeModel> get allEmployees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();
    try {
      _employees = await _service.getAll();
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
      _filtered = List.from(_employees);
    } else {
      final q = _searchQuery.toLowerCase();
      _filtered = _employees
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.role.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<bool> addEmployee({
    required String name,
    required String phone,
    required String role,
    required double dailyWage,
    required String joinDate,
  }) async {
    try {
      final employee = EmployeeModel(
        id: 'E${_uuid.v4().substring(0, 8).toUpperCase()}',
        name: name,
        phone: phone,
        role: role,
        dailyWage: dailyWage,
        joinDate: joinDate,
      );
      await _service.add(employee);
      await loadEmployees();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel updated) async {
    try {
      await _service.update(updated);
      await loadEmployees();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _service.delete(id);
      await loadEmployees();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markAttendance(
    String employeeId,
    String date,
    bool isPresent,
  ) async {
    await _service.markAttendance(employeeId, date, isPresent);
    await loadEmployees();
  }

  /// Returns salary map for current month
  Future<Map<String, double>> currentMonthSalaryReport() async {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _service.monthlySalaryReport(month);
  }

  /// Total salary payable this month across all employees
  double get totalMonthlySalary {
    final month = DateTime.now().toIso8601String().substring(0, 7);
    return _employees.fold(
      0.0,
      (sum, e) => sum + e.calculateMonthlySalary(month),
    );
  }
}
