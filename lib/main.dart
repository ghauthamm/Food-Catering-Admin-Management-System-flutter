import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/client_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/order_provider.dart';
import 'providers/purchase_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/clients/client_form_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

import 'screens/employees/employee_form_screen.dart';
import 'screens/employees/employees_screen.dart';
import 'screens/inventory/inventory_form_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/orders/order_form_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/purchases/purchase_form_screen.dart';
import 'screens/purchases/purchases_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CateringAdminApp());
}

class CateringAdminApp extends StatelessWidget {
  const CateringAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppConstants.routeLogin,
        routes: {
          AppConstants.routeLogin: (_) => const AppEntryWrapper(),
          AppConstants.routeDashboard: (_) => const DashboardScreen(),
          AppConstants.routeClients: (_) => const ClientsScreen(),
          AppConstants.routeClientForm: (_) => const ClientFormScreen(),
          AppConstants.routeOrders: (_) => const OrdersScreen(),
          AppConstants.routeOrderForm: (_) => const OrderFormScreen(),
          AppConstants.routePurchases: (_) => const PurchasesScreen(),
          AppConstants.routePurchaseForm: (_) => const PurchaseFormScreen(),
          AppConstants.routeEmployees: (_) => const EmployeesScreen(),
          AppConstants.routeEmployeeForm: (_) => const EmployeeFormScreen(),
          AppConstants.routeInventory: (_) => const InventoryScreen(),
          AppConstants.routeInventoryForm: (_) => const InventoryFormScreen(),
          AppConstants.routeReports: (_) => const ReportsScreen(),
        },
      ),
    );
  }
}

/// Checks stored session on startup and redirects accordingly.
class AppEntryWrapper extends StatefulWidget {
  const AppEntryWrapper({super.key});

  @override
  State<AppEntryWrapper> createState() => _AppEntryWrapperState();
}

class _AppEntryWrapperState extends State<AppEntryWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.initialize();
      if (!mounted) return;
      if (auth.state == AuthState.authenticated) {
        Navigator.pushReplacementNamed(context, AppConstants.routeDashboard);
      }
      // Otherwise LoginScreen is shown below
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthProvider>().state;

    if (state == AuthState.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 16),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const LoginScreen();
  }
}
