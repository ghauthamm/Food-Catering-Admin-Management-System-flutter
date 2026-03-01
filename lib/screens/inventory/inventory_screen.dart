import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_model.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import 'inventory_form_screen.dart';

/// Inventory list with low-stock alerts and stock adjustment controls.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchCtrl = TextEditingController();
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final displayList = _showLowStockOnly
        ? provider.items.where((i) => i.isLowStock).toList()
        : provider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => provider.loadInventory(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventoryFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppTheme.inventoryColor,
      ),
      body: Column(
        children: [
          // ─── Stats Banner ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Items',
                    provider.allItems.length.toString(),
                    Icons.inventory_2_outlined,
                    AppTheme.inventoryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                        () => _showLowStockOnly = !_showLowStockOnly),
                    child: _statCard(
                      'Low Stock',
                      provider.lowStockCount.toString(),
                      Icons.warning_amber_outlined,
                      provider.lowStockCount > 0
                          ? AppTheme.error
                          : AppTheme.success,
                      highlight: _showLowStockOnly,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ─── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: const Icon(Icons.search,
                    color: AppTheme.inventoryColor),
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

          if (_showLowStockOnly)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.error.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list,
                        size: 14, color: AppTheme.error),
                    const SizedBox(width: 6),
                    const Text('Showing low stock only',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.error)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showLowStockOnly = false),
                      child: const Text('Clear',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.error,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),

          // ─── List ─────────────────────────────────────────────────────────
          Expanded(
            child: LoadingOverlay(
              isLoading: provider.isLoading,
              child: displayList.isEmpty && !provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.inventoryColor),
                          const SizedBox(height: 16),
                          const Text('No inventory items',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const InventoryFormScreen())),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppTheme.inventoryColor),
                            child: const Text('Add First Item'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _InventoryCard(item: displayList[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color,
      {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.15) : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: highlight
            ? Border.all(color: color, width: 1.5)
            : Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Inventory Card ───────────────────────────────────────────────────────────

class _InventoryCard extends StatelessWidget {
  final InventoryModel item;
  const _InventoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLow = item.isLowStock;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLow
            ? BorderSide(color: AppTheme.error.withOpacity(0.4))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isLow ? AppTheme.error : AppTheme.inventoryColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLow
                        ? Icons.warning_amber_outlined
                        : Icons.inventory_2_outlined,
                    color: isLow
                        ? AppTheme.error
                        : AppTheme.inventoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (item.category != null)
                        Text(
                          item.category!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLow
                            ? AppTheme.error
                            : AppTheme.inventoryColor,
                      ),
                    ),
                    Text(
                      'Min: ${item.lowStockThreshold} ${item.unit}',
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),

            if (isLow) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 12, color: AppTheme.error),
                    SizedBox(width: 4),
                    Text(
                      'LOW STOCK — Please restock',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
            Row(
              children: [
                // Reduce stock
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _adjustStock(context, item, reduce: true),
                    icon: const Icon(Icons.remove, size: 14),
                    label: const Text('Use',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(
                          color: AppTheme.error, width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Add stock
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _adjustStock(context, item, reduce: false),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Restock',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.success,
                      side: const BorderSide(
                          color: AppTheme.success, width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.primary),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          InventoryFormScreen(existingItem: item),
                    ),
                  ),
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  onPressed: () => _delete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjustStock(
      BuildContext context, InventoryModel item,
      {required bool reduce}) async {
    final ctrl = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(reduce ? 'Use Stock' : 'Add Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.name} — Current: ${item.quantity} ${item.unit}',
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText:
                    'Amount (${item.unit})',
                hintText: '5',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              Navigator.pop(ctx, val);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (result != null && result > 0 && context.mounted) {
      final provider = context.read<InventoryProvider>();
      if (reduce) {
        await provider.reduceStock(item.id, result);
      } else {
        await provider.addStock(item.id, result);
      }
      if (context.mounted) {
        AppHelpers.showSuccess(context,
            reduce ? 'Stock reduced by $result ${item.unit}' : 'Stock added');
      }
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await AppHelpers.confirmDelete(context, item.name);
    if (confirm && context.mounted) {
      await context.read<InventoryProvider>().deleteItem(item.id);
      if (context.mounted) {
        AppHelpers.showSuccess(context, 'Item deleted');
      }
    }
  }
}
