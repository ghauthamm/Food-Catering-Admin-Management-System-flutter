import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';

/// Daily attendance marking screen for a single employee.
class AttendanceScreen extends StatefulWidget {
  final EmployeeModel employee;
  const AttendanceScreen({super.key, required this.employee});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late EmployeeModel _employee;
  String _selectedMonth = AppHelpers.currentMonth();

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  /// Returns all days in the selected month as 'YYYY-MM-DD' strings.
  List<String> get _daysInMonth {
    final parts = _selectedMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (i) =>
          '$_selectedMonth-${(i + 1).toString().padLeft(2, '0')}',
    );
  }

  bool? _attendanceFor(String date) {
    try {
      return _employee.attendance
          .firstWhere((a) => a.date == date)
          .isPresent;
    } catch (_) {
      return null; // Not marked
    }
  }

  Future<void> _toggle(String date, bool isPresent) async {
    await context
        .read<EmployeeProvider>()
        .markAttendance(_employee.id, date, isPresent);

    // Refresh local copy
    final updated = context
        .read<EmployeeProvider>()
        .allEmployees
        .firstWhere((e) => e.id == _employee.id);
    setState(() => _employee = updated);
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth;
    final presentCount = days
        .where((d) => _attendanceFor(d) == true)
        .length;
    final salary =
        presentCount * _employee.dailyWage;
    final today = AppHelpers.today();

    return Scaffold(
      appBar: AppBar(
        title: Text('${_employee.name} — Attendance'),
      ),
      body: Column(
        children: [
          // ─── Month Selector ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final date =
                        DateTime.parse('$_selectedMonth-01');
                    final prev = DateTime(date.year, date.month - 1);
                    setState(() {
                      _selectedMonth =
                          '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  AppHelpers.monthLabel(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final date =
                        DateTime.parse('$_selectedMonth-01');
                    final next =
                        DateTime(date.year, date.month + 1);
                    setState(() {
                      _selectedMonth =
                          '${next.year}-${next.month.toString().padLeft(2, '0')}';
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // ─── Summary ──────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.employeeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Present', '$presentCount days',
                    AppTheme.success),
                _stat(
                    'Absent',
                    '${days.where((d) => _attendanceFor(d) == false).length} days',
                    AppTheme.error),
                _stat('Salary',
                    AppHelpers.formatCurrency(salary),
                    AppTheme.employeeColor),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── Attendance Legend ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _legendDot(AppTheme.success, 'Present'),
                const SizedBox(width: 16),
                _legendDot(AppTheme.error, 'Absent'),
                const SizedBox(width: 16),
                _legendDot(Colors.grey.shade300, 'Not Marked'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Day Grid ─────────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: days.length,
              itemBuilder: (ctx, i) {
                final date = days[i];
                final dayNum = i + 1;
                final attendance = _attendanceFor(date);
                final isToday = date == today;

                Color bgColor;
                Color textColor;
                if (attendance == true) {
                  bgColor = AppTheme.success;
                  textColor = Colors.white;
                } else if (attendance == false) {
                  bgColor = AppTheme.error.withOpacity(0.8);
                  textColor = Colors.white;
                } else {
                  bgColor = isToday
                      ? AppTheme.primary.withOpacity(0.15)
                      : Colors.grey.shade200;
                  textColor = isToday
                      ? AppTheme.primary
                      : AppTheme.textSecondary;
                }

                return GestureDetector(
                  onTap: () => _showAttendanceDialog(
                      context, date, dayNum, attendance),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: AppTheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Future<void> _showAttendanceDialog(
    BuildContext context,
    String date,
    int day,
    bool? current,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            '${AppHelpers.monthLabel(_selectedMonth).split(' ')[0]} $day'),
        content: Text(
            'Mark attendance for ${_employee.name} on this day.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(ctx, false),
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text('Absent',
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check),
            label: const Text('Present'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success),
          ),
        ],
      ),
    );

    if (result != null) {
      await _toggle(date, result);
    }
  }
}
