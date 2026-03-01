import '../models/employee_model.dart';
import 'storage_service.dart';

/// CRUD + attendance service for employee data stored in employees.json
class EmployeeService {
  final StorageService _storage = StorageService.instance;

  Future<List<EmployeeModel>> getAll() async {
    final list = await _storage.readList(StorageFiles.employees);
    return list.map((e) => EmployeeModel.fromJson(e)).toList();
  }

  Future<EmployeeModel?> getById(String id) async {
    final employees = await getAll();
    try {
      return employees.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(EmployeeModel employee) async {
    final employees = await getAll();
    employees.add(employee);
    await _save(employees);
  }

  Future<void> update(EmployeeModel updated) async {
    final employees = await getAll();
    final index = employees.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      employees[index] = updated;
      await _save(employees);
    }
  }

  Future<void> delete(String id) async {
    final employees = await getAll();
    employees.removeWhere((e) => e.id == id);
    await _save(employees);
  }

  /// Marks attendance for an employee on a given date.
  Future<void> markAttendance(
    String employeeId,
    String date,
    bool isPresent,
  ) async {
    final employees = await getAll();
    final index = employees.indexWhere((e) => e.id == employeeId);
    if (index == -1) return;

    final employee = employees[index];
    final attendance = List<AttendanceRecord>.from(employee.attendance);

    // Remove existing entry for the date if any
    attendance.removeWhere((a) => a.date == date);
    attendance.add(AttendanceRecord(date: date, isPresent: isPresent));

    employees[index] = employee.copyWith(attendance: attendance);
    await _save(employees);
  }

  /// Returns total salary payable for a month
  Future<Map<String, double>> monthlySalaryReport(String month) async {
    final employees = await getAll();
    final report = <String, double>{};
    for (final emp in employees) {
      report[emp.name] = emp.calculateMonthlySalary(month);
    }
    return report;
  }

  Future<void> _save(List<EmployeeModel> employees) async {
    await _storage.writeList(
      StorageFiles.employees,
      employees.map((e) => e.toJson()).toList(),
    );
  }
}
