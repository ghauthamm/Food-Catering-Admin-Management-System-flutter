import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/client_model.dart';
import '../../models/order_model.dart';
import '../../providers/client_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Create or Edit an order with dynamic item list and auto-calculated total.
class OrderFormScreen extends StatefulWidget {
  final OrderModel? existingOrder;
  const OrderFormScreen({super.key, this.existingOrder});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  ClientModel? _selectedClient;
  String _selectedDate = AppHelpers.today();
  List<_ItemRow> _items = [];
  bool _isLoading = false;

  bool get _isEditing => widget.existingOrder != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
      if (_isEditing) {
        _populateForm();
      } else {
        _addItem();
      }
    });
  }

  void _populateForm() {
    final o = widget.existingOrder!;
    _selectedDate = o.date;
    _notesCtrl.text = o.notes ?? '';

    // Find selected client from provider
    final clients = context.read<ClientProvider>().allClients;
    try {
      _selectedClient =
          clients.firstWhere((c) => c.id == o.clientId);
    } catch (_) {}

    _items = o.items
        .map((i) => _ItemRow(
              nameCtrl: TextEditingController(text: i.itemName),
              qtyCtrl:
                  TextEditingController(text: i.quantity.toString()),
              priceCtrl:
                  TextEditingController(text: i.price.toString()),
            ))
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final row in _items) {
      row.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_ItemRow());
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  double get _total => _items.fold(0.0, (sum, row) {
        final qty = double.tryParse(row.qtyCtrl.text) ?? 0;
        final price = double.tryParse(row.priceCtrl.text) ?? 0;
        return sum + (qty * price);
      });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      AppHelpers.showError(context, 'Please select a client');
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<OrderProvider>();

    final items = _items
        .map((row) => OrderItem(
              itemName: row.nameCtrl.text.trim(),
              quantity: int.tryParse(row.qtyCtrl.text) ?? 0,
              price: double.tryParse(row.priceCtrl.text) ?? 0,
            ))
        .toList();

    bool success;
    if (_isEditing) {
      final total = items.fold(0.0, (sum, i) => sum + i.total);
      final updated = widget.existingOrder!.copyWith(
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        items: items,
        totalAmount: total,
        date: _selectedDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      success = await provider.updateOrder(updated);
    } else {
      success = await provider.addOrder(
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        items: items,
        date: _selectedDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Order updated!' : 'Order created!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<ClientProvider>().allClients;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Order' : 'New Order'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── Client Selection ─────────────────────────────────
                      CustomDropdownField<ClientModel>(
                        label: 'Select Client *',
                        value: _selectedClient,
                        prefixIcon: const Icon(Icons.people_outline),
                        items: clients
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text('${c.name} (${c.type})'),
                                ))
                            .toList(),
                        onChanged: (c) =>
                            setState(() => _selectedClient = c),
                        validator: (_) => _selectedClient == null
                            ? 'Please select a client'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // ─── Date ─────────────────────────────────────────────
                      DatePickerField(
                        label: 'Order Date *',
                        selectedDate: _selectedDate,
                        onDateSelected: (d) =>
                            setState(() => _selectedDate = d),
                      ),
                      const SizedBox(height: 24),

                      // ─── Order Items ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order Items',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add_circle_outline,
                                size: 18),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Header row
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text('Item Name',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Qty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Price',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(width: 32),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Item rows
                      ...List.generate(
                        _items.length,
                        (i) => _ItemRowWidget(
                          key: ValueKey(i),
                          row: _items[i],
                          onRemove: () => _removeItem(i),
                          onChanged: () => setState(() {}),
                        ),
                      ),

                      const Divider(height: 24),

                      // ─── Total ────────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AppHelpers.formatCurrency(_total),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ─── Notes ────────────────────────────────────────────
                      CustomTextField(
                        label: 'Notes (Optional)',
                        hint: 'Special instructions...',
                        controller: _notesCtrl,
                        maxLines: 2,
                        prefixIcon: const Icon(Icons.note_outlined),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ─── Submit ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    _isEditing ? 'Update Order' : 'Create Order',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Item Row Model ───────────────────────────────────────────────────────────

class _ItemRow {
  final TextEditingController nameCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController priceCtrl;

  _ItemRow({
    TextEditingController? nameCtrl,
    TextEditingController? qtyCtrl,
    TextEditingController? priceCtrl,
  })  : nameCtrl = nameCtrl ?? TextEditingController(),
        qtyCtrl = qtyCtrl ?? TextEditingController(),
        priceCtrl = priceCtrl ?? TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
  }
}

// ─── Item Row Widget ──────────────────────────────────────────────────────────

class _ItemRowWidget extends StatelessWidget {
  final _ItemRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ItemRowWidget({
    super.key,
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Item name
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: row.nameCtrl,
              onChanged: (_) => onChanged(),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Meals',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 6),

          // Quantity
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.qtyCtrl,
              onChanged: (_) => onChanged(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '100',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Req';
                if ((int.tryParse(v) ?? 0) <= 0) return '>0';
                return null;
              },
            ),
          ),
          const SizedBox(width: 6),

          // Price
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: row.priceCtrl,
              onChanged: (_) => onChanged(),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '80',
                prefixText: '₹',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Req';
                if ((double.tryParse(v) ?? 0) <= 0) return '>0';
                return null;
              },
            ),
          ),
          const SizedBox(width: 4),

          // Remove
          IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Colors.red, size: 20),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}
