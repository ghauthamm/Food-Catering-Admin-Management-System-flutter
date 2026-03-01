import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/purchase_model.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import 'purchase_form_screen.dart';

/// Lists all purchases / expenses with search and totals.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseProvider>().loadPurchases();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PurchaseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases & Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => provider.loadPurchases(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Purchase'),
        backgroundColor: AppTheme.purchaseColor,
      ),
      body: Column(
        children: [
          // ─── Monthly Summary Banner ───────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.purchaseColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppTheme.purchaseColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: AppTheme.purchaseColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Month Expense',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        AppHelpers.formatCurrency(provider.monthExpense),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.purchaseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${provider.allPurchases.where((p) => p.date.startsWith(AppHelpers.currentMonth())).length} entries',
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
                hintText: 'Search by item or vendor...',
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.purchaseColor),
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

          // ─── List ─────────────────────────────────────────────────────────
          Expanded(
            child: LoadingOverlay(
              isLoading: provider.isLoading,
              child: provider.purchases.isEmpty && !provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined,
                              size: 64, color: AppTheme.purchaseColor),
                          const SizedBox(height: 16),
                          const Text('No purchases recorded',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const PurchaseFormScreen())),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.purchaseColor),
                            child: const Text('Add First Purchase'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.purchases.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _PurchaseCard(purchase: provider.purchases[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Purchase Card ────────────────────────────────────────────────────────────

class _PurchaseCard extends StatelessWidget {
  final PurchaseModel purchase;
  const _PurchaseCard({required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.purchaseColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.shopping_cart_outlined,
              color: AppTheme.purchaseColor, size: 22),
        ),
        title: Text(
          purchase.itemName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${purchase.vendorName} • ${AppHelpers.formatDate(purchase.date)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${purchase.quantity} ${purchase.unit}${purchase.gstIncluded ? ' • GST ${purchase.gstPercent?.toInt()}%' : ''}',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppHelpers.formatCurrency(purchase.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.purchaseColor,
              ),
            ),
            if (purchase.category != null)
              Text(
                purchase.category!,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  PurchaseFormScreen(existingPurchase: purchase)),
        ),
        onLongPress: () => _delete(context),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirm =
        await AppHelpers.confirmDelete(context, purchase.itemName);
    if (confirm && context.mounted) {
      await context.read<PurchaseProvider>().deletePurchase(purchase.id);
      if (context.mounted) {
        AppHelpers.showSuccess(context, 'Purchase deleted');
      }
    }
  }
}
