// Attendance Record sub-model
class AttendanceRecord {
  final String date;
  final bool isPresent;
  final String? note;

  AttendanceRecord({
    required this.date,
    required this.isPresent,
    this.note,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        date: json['date'] ?? '',
        isPresent: json['isPresent'] ?? false,
        note: json['note'],
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'isPresent': isPresent,
        'note': note,
      };
}

// Employee Model
class EmployeeModel {
  final String id;
  final String name;
  final String phone;
  final String role; // Cook / Helper / Driver
  final double dailyWage;
  final String joinDate;
  final bool isActive;
  final List<AttendanceRecord> attendance;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.dailyWage,
    required this.joinDate,
    this.isActive = true,
    this.attendance = const [],
  });

  /// Calculate salary for a given month (format: 'YYYY-MM')
  double calculateMonthlySalary(String month) {
    final presentDays = attendance
        .where((a) => a.date.startsWith(month) && a.isPresent)
        .length;
    return presentDays * dailyWage;
  }

  /// Days present in a given month
  int presentDaysInMonth(String month) =>
      attendance.where((a) => a.date.startsWith(month) && a.isPresent).length;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        role: json['role'] ?? 'Helper',
        dailyWage: (json['dailyWage'] ?? 0).toDouble(),
        joinDate:
            json['joinDate'] ?? DateTime.now().toIso8601String().split('T').first,
        isActive: json['isActive'] ?? true,
        attendance: (json['attendance'] as List<dynamic>? ?? [])
            .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role,
        'dailyWage': dailyWage,
        'joinDate': joinDate,
        'isActive': isActive,
        'attendance': attendance.map((e) => e.toJson()).toList(),
      };

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    double? dailyWage,
    String? joinDate,
    bool? isActive,
    List<AttendanceRecord>? attendance,
  }) =>
      EmployeeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        dailyWage: dailyWage ?? this.dailyWage,
        joinDate: joinDate ?? this.joinDate,
        isActive: isActive ?? this.isActive,
        attendance: attendance ?? this.attendance,
      );
}

const List<String> employeeRoles = ['Cook', 'Helper', 'Driver', 'Cleaner', 'Manager'];
