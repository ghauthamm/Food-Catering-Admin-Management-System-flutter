import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Side navigation drawer used in smaller screens or as supplementary nav.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Drawer(
      child: Column(
        children: [
          // ─── Header ───────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Admin',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'ADMIN',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Nav Items ────────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  color: AppTheme.primary,
                  onTap: () => _navigate(context, AppConstants.routeDashboard),
                ),
                _DrawerItem(
                  icon: Icons.people_outline,
                  label: 'Clients',
                  color: AppTheme.clientColor,
                  onTap: () => _navigate(context, AppConstants.routeClients),
                ),
                _DrawerItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  color: AppTheme.orderColor,
                  onTap: () => _navigate(context, AppConstants.routeOrders),
                ),
                _DrawerItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Purchases',
                  color: AppTheme.purchaseColor,
                  onTap: () => _navigate(context, AppConstants.routePurchases),
                ),
                _DrawerItem(
                  icon: Icons.badge_outlined,
                  label: 'Employees',
                  color: AppTheme.employeeColor,
                  onTap: () => _navigate(context, AppConstants.routeEmployees),
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Inventory',
                  color: AppTheme.inventoryColor,
                  onTap: () => _navigate(context, AppConstants.routeInventory),
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  color: AppTheme.reportColor,
                  onTap: () => _navigate(context, AppConstants.routeReports),
                ),
                const Divider(height: 24),
                _DrawerItem(
                  icon: Icons.logout_outlined,
                  label: 'Logout',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                          context, AppConstants.routeLogin);
                    }
                  },
                ),
              ],
            ),
          ),

          // ─── Footer ───────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Catering Admin v${AppConstants.appVersion}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF95A5A6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C3E50),
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
