import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_overlay.dart';
import 'order_form_screen.dart';

/// Lists all orders with status filtering, search and actions.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => provider.loadOrders(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const OrderFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
      body: Column(
        children: [
          // ─── Search & Filter ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: provider.search,
              decoration: InputDecoration(
                hintText: 'Search by client or order ID...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.orderColor),
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

          // ─── Status Filter Chips ──────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', ...orderStatuses].map((status) {
                  final isSelected = provider.statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        status == 'all' ? 'All' : status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => provider.setStatusFilter(status),
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.orderColor,
                      checkmarkColor: Colors.white,
                      side:
                          BorderSide(color: AppTheme.orderColor.withOpacity(0.3)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─── Order List ───────────────────────────────────────────────────
          Expanded(
            child: LoadingOverlay(
              isLoading: provider.isLoading,
              child: provider.orders.isEmpty && !provider.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              size: 64, color: AppTheme.orderColor),
                          const SizedBox(height: 16),
                          const Text('No orders found',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const OrderFormScreen())),
                            child: const Text('Create First Order'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: provider.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) =>
                          _OrderCard(order: provider.orders[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.clientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order #${order.id} • ${AppHelpers.formatDate(order.date)}',
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
                      AppHelpers.formatCurrency(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(status: order.status),
                  ],
                ),
              ],
            ),

            // Items summary
            const Divider(height: 16),
            ...order.items.take(3).map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text(
                          '${item.quantity} × ₹${item.price}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (order.items.length > 3)
              Text(
                '+${order.items.length - 3} more items',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),

            // Action Row
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderFormScreen(existingOrder: order),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusUpdateButton(order: order),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteOrder(context),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteOrder(BuildContext context) async {
    final confirm = await AppHelpers.confirmDelete(
        context, 'Order #${order.id}');
    if (confirm && context.mounted) {
      await context.read<OrderProvider>().deleteOrder(order.id);
      if (context.mounted) {
        AppHelpers.showSuccess(context, 'Order deleted');
      }
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppHelpers.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _StatusUpdateButton extends StatelessWidget {
  final OrderModel order;
  const _StatusUpdateButton({required this.order});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.update_outlined, size: 14, color: AppTheme.primary),
            SizedBox(width: 4),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => orderStatuses
          .map((s) => PopupMenuItem(
                value: s,
                child: Text(s.toUpperCase()),
              ))
          .toList(),
      onSelected: (newStatus) async {
        await context.read<OrderProvider>().updateStatus(order.id, newStatus);
        if (context.mounted) {
          AppHelpers.showSuccess(
              context, 'Status updated to $newStatus');
        }
      },
    );
  }
}
