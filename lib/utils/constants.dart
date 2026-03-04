/// Application-wide constants
class AppConstants {
  static const String appName = 'Catering Admin';
  static const String appVersion = '1.0.0';

  // ─── Route Names ─────────────────────────────────────────────────────────────
  static const String routeLogin = '/login';
  static const String routeDashboard = '/dashboard';
  static const String routeClients = '/clients';
  static const String routeOrders = '/orders';
  static const String routePurchases = '/purchases';
  static const String routeEmployees = '/employees';
  static const String routeInventory = '/inventory';
  static const String routeReports = '/reports';
  static const String routeClientForm = '/clients/form';
  static const String routeOrderForm = '/orders/form';
  static const String routePurchaseForm = '/purchases/form';
  static const String routeEmployeeForm = '/employees/form';
  static const String routeAttendance = '/employees/attendance';
  static const String routeInventoryForm = '/inventory/form';
  static const String routeMenu = '/menu';
  static const String routeMenuForm = '/menu/form';

  // ─── Shared Prefs Keys ────────────────────────────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefUserId = 'user_id';
}

/// Bottom navigation tab indices
class NavIndex {
  static const int dashboard = 0;
  static const int clients = 1;
  static const int orders = 2;
  static const int purchases = 3;
  static const int employees = 4;
}
