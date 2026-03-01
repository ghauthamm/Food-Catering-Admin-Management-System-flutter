import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/purchase_model.dart';
import '../../providers/purchase_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Add or Edit a purchase / expense entry.
class PurchaseFormScreen extends StatefulWidget {
  final PurchaseModel? existingPurchase;
  const PurchaseFormScreen({super.key, this.existingPurchase});

  @override
  State<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends State<PurchaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorCtrl = TextEditingController();
  final _itemCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _gstPercentCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedUnit = 'kg';
  String? _selectedCategory;
  String _selectedDate = AppHelpers.today();
  bool _gstIncluded = false;
  bool _isLoading = false;

  bool get _isEditing => widget.existingPurchase != null;

  double get _gstAmount {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final gst = double.tryParse(_gstPercentCtrl.text) ?? 0;
    return _gstIncluded ? price * gst / 100 : 0;
  }

  double get _total => (double.tryParse(_priceCtrl.text) ?? 0) + _gstAmount;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.existingPurchase!;
      _vendorCtrl.text = p.vendorName;
      _itemCtrl.text = p.itemName;
      _qtyCtrl.text = p.quantity.toString();
      _priceCtrl.text = p.price.toString();
      _selectedUnit = p.unit;
      _selectedCategory = p.category;
      _selectedDate = p.date;
      _gstIncluded = p.gstIncluded;
      _gstPercentCtrl.text = p.gstPercent?.toString() ?? '';
      _notesCtrl.text = p.notes ?? '';
    }
  }

  @override
  void dispose() {
    _vendorCtrl.dispose();
    _itemCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _gstPercentCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<PurchaseProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.existingPurchase!.copyWith(
        vendorName: _vendorCtrl.text.trim(),
        itemName: _itemCtrl.text.trim(),
        quantity: double.tryParse(_qtyCtrl.text) ?? 0,
        unit: _selectedUnit,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        gstIncluded: _gstIncluded,
        gstPercent: _gstIncluded
            ? double.tryParse(_gstPercentCtrl.text)
            : null,
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      success = await provider.updatePurchase(updated);
    } else {
      success = await provider.addPurchase(
        vendorName: _vendorCtrl.text.trim(),
        itemName: _itemCtrl.text.trim(),
        quantity: double.tryParse(_qtyCtrl.text) ?? 0,
        unit: _selectedUnit,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        gstIncluded: _gstIncluded,
        gstPercent: _gstIncluded
            ? double.tryParse(_gstPercentCtrl.text)
            : null,
        date: _selectedDate,
        category: _selectedCategory,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Purchase updated!' : 'Purchase added!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save purchase');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Purchase' : 'Add Purchase'),
        backgroundColor: AppTheme.purchaseColor,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Vendor ──────────────────────────────────────────────────
                CustomTextField(
                  label: 'Vendor Name *',
                  hint: 'Fresh Mart Supplier',
                  controller: _vendorCtrl,
                  prefixIcon: const Icon(Icons.store_outlined),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // ─── Item Name ───────────────────────────────────────────────
                CustomTextField(
                  label: 'Item Name *',
                  hint: 'Rice / Oil / Tomatoes',
                  controller: _itemCtrl,
                  prefixIcon: const Icon(Icons.inventory_outlined),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // ─── Quantity & Unit ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Quantity *',
                        hint: '10',
                        controller: _qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: const Icon(Icons.scale_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? 0) <= 0) return '>0';
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomDropdownField<String>(
                        label: 'Unit',
                        value: _selectedUnit,
                        items: purchaseUnits
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─── Price ───────────────────────────────────────────────────
                CustomTextField(
                  label: 'Price (₹) *',
                  hint: '500',
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if ((double.tryParse(v) ?? 0) <= 0) return '>0';
                    return null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // ─── Category ────────────────────────────────────────────────
                CustomDropdownField<String>(
                  label: 'Category (Optional)',
                  value: _selectedCategory,
                  prefixIcon: const Icon(Icons.label_outline),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...purchaseCategories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 16),

                // ─── Date ────────────────────────────────────────────────────
                DatePickerField(
                  label: 'Purchase Date *',
                  selectedDate: _selectedDate,
                  onDateSelected: (d) => setState(() => _selectedDate = d),
                ),
                const SizedBox(height: 16),

                // ─── GST Toggle ───────────────────────────────────────────────
                SwitchListTile(
                  value: _gstIncluded,
                  onChanged: (v) => setState(() => _gstIncluded = v),
                  title: const Text('GST Applicable'),
                  subtitle: const Text('Toggle to add GST on this purchase'),
                  activeColor: AppTheme.purchaseColor,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_gstIncluded) ...[
                  CustomTextField(
                    label: 'GST Percentage *',
                    hint: '18',
                    controller: _gstPercentCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    suffixIcon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Text('%',
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary)),
                    ),
                    validator: (v) {
                      if (_gstIncluded &&
                          (v == null ||
                              v.isEmpty ||
                              (double.tryParse(v) ?? 0) <= 0)) {
                        return 'Enter valid GST %';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),

                // ─── Total Preview ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.purchaseColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        AppHelpers.formatCurrency(_total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.purchaseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Notes ───────────────────────────────────────────────────
                CustomTextField(
                  label: 'Notes (Optional)',
                  controller: _notesCtrl,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.purchaseColor),
                  child: Text(
                      _isEditing ? 'Update Purchase' : 'Add Purchase'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
