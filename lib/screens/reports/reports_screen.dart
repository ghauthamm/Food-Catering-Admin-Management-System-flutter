import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/stat_card.dart';

/// Comprehensive reports screen: revenue, expenses, profit and salary.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMonth = AppHelpers.currentMonth();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<OrderProvider>().loadOrders(),
      context.read<PurchaseProvider>().loadPurchases(),
      context.read<EmployeeProvider>().loadEmployees(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Financial'),
            Tab(text: 'Expenses'),
            Tab(text: 'Salary'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ─── Month Selector ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final date = DateTime.parse('$_selectedMonth-01');
                    final prev = DateTime(date.year, date.month - 1);
                    setState(() {
                      _selectedMonth =
                          '${prev.year}-${prev.month.toString().padLeft(2, '0')}';
                    });
                  },
                  icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppHelpers.monthLabel(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final date = DateTime.parse('$_selectedMonth-01');
                    final next = DateTime(date.year, date.month + 1);
                    setState(() {
                      _selectedMonth =
                          '${next.year}-${next.month.toString().padLeft(2, '0')}';
                    });
                  },
                  icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FinancialTab(month: _selectedMonth),
                _ExpensesTab(month: _selectedMonth),
                _SalaryTab(month: _selectedMonth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Financial Report Tab ─────────────────────────────────────────────────────

class _FinancialTab extends StatelessWidget {
  final String month;
  const _FinancialTab({required this.month});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final purchases = context.watch<PurchaseProvider>();
    final employees = context.watch<EmployeeProvider>();

    final monthOrders = orders.allOrders
        .where((o) => o.date.startsWith(month) && o.status != 'cancelled')
        .toList();
    final revenue = monthOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

    final monthPurchases = purchases.allPurchases
        .where((p) => p.date.startsWith(month))
        .toList();
    final expense = monthPurchases.fold(0.0, (sum, p) => sum + p.totalPrice);

    final salary = employees.allEmployees.fold(
        0.0, (sum, e) => sum + e.calculateMonthlySalary(month));

    final totalExpense = expense + salary;
    final profit = revenue - totalExpense;
    final profitMargin = revenue > 0 ? (profit / revenue * 100) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                label: 'Revenue',
                value: AppHelpers.formatCurrency(revenue),
                icon: Icons.trending_up,
                color: AppTheme.success,
              ),
              StatCard(
                label: 'Purchase Expense',
                value: AppHelpers.formatCurrency(expense),
                icon: Icons.shopping_cart_outlined,
                color: AppTheme.purchaseColor,
              ),
              StatCard(
                label: 'Salary Paid',
                value: AppHelpers.formatCurrency(salary),
                icon: Icons.payments_outlined,
                color: AppTheme.employeeColor,
              ),
              StatCard(
                label: 'Net Profit',
                value: AppHelpers.formatCurrency(profit),
                icon: profit >= 0
                    ? Icons.arrow_upward_outlined
                    : Icons.arrow_downward_outlined,
                color: profit >= 0 ? AppTheme.success : AppTheme.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SummaryTile(
                    label: 'Total Orders',
                    value: '${monthOrders.length} orders',
                    color: AppTheme.orderColor,
                    icon: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 8),
                  SummaryTile(
                    label: 'Total Revenue',
                    value: AppHelpers.formatCurrency(revenue),
                    color: AppTheme.success,
                    icon: Icons.trending_up,
                  ),
                  const SizedBox(height: 8),
                  SummaryTile(
                    label: 'Total Expense',
                    value: AppHelpers.formatCurrency(totalExpense),
                    color: AppTheme.purchaseColor,
                    icon: Icons.trending_down,
                  ),
                  const Divider(height: 20),
                  SummaryTile(
                    label: 'Net Profit',
                    value: AppHelpers.formatCurrency(profit),
                    color: profit >= 0 ? AppTheme.success : AppTheme.error,
                    icon: profit >= 0
                        ? Icons.attach_money
                        : Icons.money_off,
                  ),
                  const SizedBox(height: 8),
                  SummaryTile(
                    label: 'Profit Margin',
                    value: '${profitMargin.toStringAsFixed(1)}%',
                    color: profitMargin >= 20
                        ? AppTheme.success
                        : AppTheme.warning,
                    icon: Icons.pie_chart_outline,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Pie Chart
          if (revenue > 0) ...[
            const Text(
              'Revenue vs Expense Breakdown',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: expense,
                      color: AppTheme.purchaseColor,
                      title:
                          'Purchases\n${(expense / (revenue > 0 ? revenue : 1) * 100).toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: salary,
                      color: AppTheme.employeeColor,
                      title:
                          'Salary\n${(salary / (revenue > 0 ? revenue : 1) * 100).toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    if (profit > 0)
                      PieChartSectionData(
                        value: profit,
                        color: AppTheme.success,
                        title:
                            'Profit\n${profitMargin.toStringAsFixed(0)}%',
                        radius: 80,
                        titleStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Expenses Tab ─────────────────────────────────────────────────────────────

class _ExpensesTab extends StatelessWidget {
  final String month;
  const _ExpensesTab({required this.month});

  @override
  Widget build(BuildContext context) {
    final purchases = context.watch<PurchaseProvider>();
    final monthPurchases = purchases.allPurchases
        .where((p) => p.date.startsWith(month))
        .toList();

    // Group by category
    final Map<String, double> byCategory = {};
    for (final p in monthPurchases) {
      final cat = p.category ?? 'Other';
      byCategory[cat] = (byCategory[cat] ?? 0) + p.totalPrice;
    }

    final total = monthPurchases.fold(0.0, (sum, p) => sum + p.totalPrice);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.purchaseColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: AppTheme.purchaseColor, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Expense',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    Text(
                      AppHelpers.formatCurrency(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.purchaseColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${monthPurchases.length} entries',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (byCategory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No expense data for this month.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else ...[
            const Text(
              'By Category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...byCategory.entries.map((e) {
              final pct = total > 0 ? e.value / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text(AppHelpers.formatCurrency(e.value),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.purchaseColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor:
                            AppTheme.purchaseColor.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.purchaseColor),
                        minHeight: 6,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(1)}% of total',
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            const Text(
              'All Entries',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...monthPurchases.map(
              (p) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  title: Text(p.itemName,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${p.vendorName} • ${AppHelpers.formatDate(p.date)}'),
                  trailing: Text(
                    AppHelpers.formatCurrency(p.totalPrice),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.purchaseColor),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Salary Tab ───────────────────────────────────────────────────────────────

class _SalaryTab extends StatelessWidget {
  final String month;
  const _SalaryTab({required this.month});

  @override
  Widget build(BuildContext context) {
    final employees = context.watch<EmployeeProvider>();
    final activeEmployees =
        employees.allEmployees.where((e) => e.isActive).toList();

    final total = activeEmployees.fold(
        0.0, (sum, e) => sum + e.calculateMonthlySalary(month));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.employeeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    color: AppTheme.employeeColor, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Salary Payable',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    Text(
                      AppHelpers.formatCurrency(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.employeeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (activeEmployees.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No active employees.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else ...[
            const Text(
              'Employee Salary Breakdown',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...activeEmployees.map((emp) {
              final presentDays = emp.presentDaysInMonth(month);
              final salary = emp.calculateMonthlySalary(month);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            AppTheme.employeeColor.withOpacity(0.12),
                        child: Text(
                          emp.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.employeeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${emp.role} • ₹${emp.dailyWage.toStringAsFixed(0)}/day • $presentDays days',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppHelpers.formatCurrency(salary),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.employeeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
