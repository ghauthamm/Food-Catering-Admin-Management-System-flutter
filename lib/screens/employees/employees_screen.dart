import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import 'employee_form_screen.dart';
import 'attendance_screen.dart';

/// Employee list with attendance marking and salary overview.
class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final month = AppHelpers.monthLabel(AppHelpers.currentMonth());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => provider.loadEmployees(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
        backgroundColor: AppTheme.employeeColor,
      ),
      body: Column(
        children: [
          // ─── Monthly Salary Summary ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.employeeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.employeeColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: AppTheme.employeeColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$month — Salary Payable',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        AppHelpers.formatCurrency(
                            provider.totalMonthlySalary),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.employeeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${provider.allEmployees.where((e) => e.isActive).length} active',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ─── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.employeeColor),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          provider.search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ─── Employee List ────────────────────────────────────────────────
          Expanded(
            child: LoadingOverlay(
              isLoading: provider.isLoading,
              child: provider.employees.isEmpty && !provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 64, color: AppTheme.employeeColor),
                          const SizedBox(height: 16),
                          const Text('No employees found',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const EmployeeFormScreen())),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.employeeColor),
                            child: const Text('Add First Employee'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.employees.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _EmployeeCard(employee: provider.employees[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Employee Card ────────────────────────────────────────────────────────────

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    final month = AppHelpers.currentMonth();
    final salary = employee.calculateMonthlySalary(month);
    final presentDays = employee.presentDaysInMonth(month);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      AppTheme.employeeColor.withOpacity(0.12),
                  child: Text(
                    employee.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.employeeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              employee.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!employee.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.employeeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              employee.role,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.employeeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 11,
                                  color: AppTheme.textSecondary),
                              const SizedBox(width: 2),
                              Text(
                                employee.phone,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Wage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${employee.dailyWage.toStringAsFixed(0)}/day',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.employeeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 16),

            // Attendance & Salary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(Icons.calendar_today_outlined,
                    '$presentDays days present this month'),
                _infoChip(Icons.currency_rupee_outlined,
                    'Salary: ${AppHelpers.formatCurrency(salary)}'),
              ],
            ),
            const SizedBox(height: 8),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AttendanceScreen(employee: employee),
                      ),
                    ),
                    icon: const Icon(Icons.how_to_reg_outlined, size: 16),
                    label: const Text('Attendance',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.employeeColor,
                      side: const BorderSide(color: AppTheme.employeeColor),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeFormScreen(
                            existingEmployee: employee),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label:
                        const Text('Edit', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  onPressed: () => _delete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirm =
        await AppHelpers.confirmDelete(context, employee.name);
    if (confirm && context.mounted) {
      await context.read<EmployeeProvider>().deleteEmployee(employee.id);
      if (context.mounted) {
        AppHelpers.showSuccess(context, 'Employee removed');
      }
    }
  }
}
