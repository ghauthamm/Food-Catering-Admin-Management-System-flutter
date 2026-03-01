import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_overlay.dart';

/// Main dashboard with KPI cards and quick navigation.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<ClientProvider>().loadClients(),
      context.read<OrderProvider>().loadOrders(),
      context.read<PurchaseProvider>().loadPurchases(),
      context.read<EmployeeProvider>().loadEmployees(),
      context.read<InventoryProvider>().loadInventory(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final clients = context.watch<ClientProvider>();
    final purchases = context.watch<PurchaseProvider>();
    final employees = context.watch<EmployeeProvider>();
    final inventory = context.watch<InventoryProvider>();

    final month = AppHelpers.monthLabel(AppHelpers.currentMonth());
    final revenue = orders.monthRevenue;
    final expense = purchases.monthExpense;
    final profit = revenue - expense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _loadAll,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                    context, AppConstants.routeLogin);
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: RefreshIndicator(
          onRefresh: _loadAll,
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Greeting ─────────────────────────────────────────────────
                _buildGreeting(auth),
                const SizedBox(height: 20),

                // ─── Monthly Summary Banner ───────────────────────────────────
                _buildMonthBanner(month, revenue, expense, profit),
                const SizedBox(height: 20),

                // ─── KPI Cards Grid ───────────────────────────────────────────
                _sectionTitle('Overview'),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(
                      label: 'Total Clients',
                      value: clients.allClients.length.toString(),
                      icon: Icons.people_outline,
                      color: AppTheme.clientColor,
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeClients),
                    ),
                    StatCard(
                      label: "This Month Orders",
                      value: orders.allOrders
                          .where((o) => o.date
                              .startsWith(AppHelpers.currentMonth()))
                          .length
                          .toString(),
                      icon: Icons.receipt_long_outlined,
                      color: AppTheme.orderColor,
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeOrders),
                    ),
                    StatCard(
                      label: 'Employees',
                      value: employees.allEmployees
                          .where((e) => e.isActive)
                          .length
                          .toString(),
                      icon: Icons.badge_outlined,
                      color: AppTheme.employeeColor,
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeEmployees),
                    ),
                    StatCard(
                      label: 'Low Stock Items',
                      value: inventory.lowStockCount.toString(),
                      icon: Icons.warning_amber_outlined,
                      color: inventory.lowStockCount > 0
                          ? AppTheme.error
                          : AppTheme.success,
                      subtitle: inventory.lowStockCount > 0
                          ? 'Needs attention'
                          : 'All good',
                      onTap: () => Navigator.pushNamed(
                          context, AppConstants.routeInventory),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Quick Actions ────────────────────────────────────────────
                _sectionTitle('Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // ─── Recent Orders ────────────────────────────────────────────
                _sectionTitle('Recent Orders'),
                const SizedBox(height: 12),
                _buildRecentOrders(orders),
                const SizedBox(height: 24),

                // ─── Low Stock Alert ──────────────────────────────────────────
                if (inventory.lowStockItems.isNotEmpty) ...[
                  _sectionTitle('⚠️ Low Stock Alerts'),
                  const SizedBox(height: 12),
                  _buildLowStockAlerts(inventory),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(AuthProvider auth) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                auth.currentUser?.name ?? 'Admin',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            auth.currentUser?.role.toUpperCase() ?? 'ADMIN',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthBanner(
      String month, double revenue, double expense, double profit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Net Profit: ${AppHelpers.formatCurrency(profit)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _bannerStat(
                  'Revenue', AppHelpers.formatCurrency(revenue), Colors.white),
              const SizedBox(width: 24),
              _bannerStat(
                  'Expense', AppHelpers.formatCurrency(expense), Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction('New Order', Icons.add_circle_outline, AppTheme.orderColor,
          AppConstants.routeOrders),
      _QuickAction('Add Client', Icons.person_add_outlined,
          AppTheme.clientColor, AppConstants.routeClients),
      _QuickAction('Add Purchase', Icons.shopping_bag_outlined,
          AppTheme.purchaseColor, AppConstants.routePurchases),
      _QuickAction('Attendance', Icons.how_to_reg_outlined,
          AppTheme.employeeColor, AppConstants.routeEmployees),
      _QuickAction('Reports', Icons.bar_chart_outlined, AppTheme.reportColor,
          AppConstants.routeReports),
      _QuickAction('Inventory', Icons.inventory_2_outlined,
          AppTheme.inventoryColor, AppConstants.routeInventory),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: actions
          .map((a) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, a.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: a.color.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(a.icon, color: a.color, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRecentOrders(OrderProvider orders) {
    final recent = orders.allOrders.take(5).toList();
    if (recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No orders yet.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }
    return Card(
      child: Column(
        children: recent
            .map(
              (o) => ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.orderColor.withOpacity(0.12),
                  child: Text(
                    o.clientName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.orderColor,
                    ),
                  ),
                ),
                title: Text(
                  o.clientName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  AppHelpers.formatDate(o.date),
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppHelpers.formatCurrency(o.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            AppHelpers.statusColor(o.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        o.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppHelpers.statusColor(o.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLowStockAlerts(InventoryProvider inventory) {
    return Card(
      color: AppTheme.error.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.error.withOpacity(0.2)),
      ),
      elevation: 0,
      child: Column(
        children: inventory.lowStockItems
            .take(5)
            .map(
              (item) => ListTile(
                leading: const Icon(Icons.warning_amber,
                    color: AppTheme.error, size: 20),
                title: Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Text(
                  '${item.quantity} ${item.unit}',
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _QuickAction(this.label, this.icon, this.color, this.route);
}
