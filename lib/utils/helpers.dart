import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// General utility/helper methods used across the app.
class AppHelpers {
  // ─── Currency ─────────────────────────────────────────────────────────────────
  static final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  static String formatCurrency(double amount) => _currency.format(amount);

  // ─── Date ─────────────────────────────────────────────────────────────────────

  /// Formats a 'YYYY-MM-DD' string to '01 Jan 2026'
  static String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Returns today's date as 'YYYY-MM-DD'
  static String today() =>
      DateTime.now().toIso8601String().split('T').first;

  /// Returns current month as 'YYYY-MM'
  static String currentMonth() =>
      DateTime.now().toIso8601String().substring(0, 7);

  /// Returns month display label e.g. 'March 2026'
  static String monthLabel(String month) {
    try {
      final date = DateTime.parse('$month-01');
      return DateFormat('MMMM yyyy').format(date);
    } catch (_) {
      return month;
    }
  }

  // ─── Snackbar ────────────────────────────────────────────────────────────────

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Confirm Dialog ──────────────────────────────────────────────────────────

  static Future<bool> confirmDelete(BuildContext context, String itemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Status Badge Color ───────────────────────────────────────────────────────

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF27AE60);
      case 'pending':
        return const Color(0xFFF39C12);
      case 'cancelled':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF7F8C9A);
    }
  }
}
