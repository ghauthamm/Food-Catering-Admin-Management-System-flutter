import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_model.dart';
import '../../models/purchase_model.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Add or Edit inventory / raw material item.
class InventoryFormScreen extends StatefulWidget {
  final InventoryModel? existingItem;
  const InventoryFormScreen({super.key, this.existingItem});

  @override
  State<InventoryFormScreen> createState() =>
      _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _thresholdCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedUnit = 'kg';
  String? _selectedCategory;
  bool _isLoading = false;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final item = widget.existingItem!;
      _nameCtrl.text = item.name;
      _qtyCtrl.text = item.quantity.toString();
      _thresholdCtrl.text = item.lowStockThreshold.toString();
      _priceCtrl.text = item.pricePerUnit?.toString() ?? '';
      _selectedUnit = item.unit;
      _selectedCategory = item.category;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _thresholdCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<InventoryProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.existingItem!.copyWith(
        name: _nameCtrl.text.trim(),
        unit: _selectedUnit,
        quantity: double.tryParse(_qtyCtrl.text) ?? 0,
        lowStockThreshold: double.tryParse(_thresholdCtrl.text) ?? 5,
        pricePerUnit: _priceCtrl.text.isNotEmpty
            ? double.tryParse(_priceCtrl.text)
            : null,
        category: _selectedCategory,
        lastUpdated:
            DateTime.now().toIso8601String().split('T').first,
      );
      success = await provider.updateItem(updated);
    } else {
      success = await provider.addItem(
        name: _nameCtrl.text.trim(),
        unit: _selectedUnit,
        quantity: double.tryParse(_qtyCtrl.text) ?? 0,
        lowStockThreshold: double.tryParse(_thresholdCtrl.text) ?? 5,
        pricePerUnit: _priceCtrl.text.isNotEmpty
            ? double.tryParse(_priceCtrl.text)
            : null,
        category: _selectedCategory,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Item updated!' : 'Item added!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save item');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : 'Add Inventory Item'),
        backgroundColor: AppTheme.inventoryColor,
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
                // ─── Name ────────────────────────────────────────────────────
                CustomTextField(
                  label: 'Item Name *',
                  hint: 'Rice / Tomatoes / Oil',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.inventory_outlined),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
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
                    ...inventoryCategories.map(
                      (c) =>
                          DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 16),

                // ─── Quantity & Unit ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomTextField(
                        label: 'Current Stock *',
                        hint: '50',
                        controller: _qtyCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        prefixIcon: const Icon(Icons.scale_outlined),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if ((double.tryParse(v) ?? -1) < 0) return '>= 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomDropdownField<String>(
                        label: 'Unit',
                        value: _selectedUnit,
                        items: purchaseUnits
                            .map((u) => DropdownMenuItem(
                                value: u, child: Text(u)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedUnit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ─── Low Stock Threshold ──────────────────────────────────────
                CustomTextField(
                  label: 'Low Stock Alert Threshold *',
                  hint: '5',
                  controller: _thresholdCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.warning_amber_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if ((double.tryParse(v) ?? -1) < 0) return '>= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Price Per Unit (Optional) ────────────────────────────────
                CustomTextField(
                  label: 'Price Per Unit ₹ (Optional)',
                  hint: '45',
                  controller: _priceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon:
                      const Icon(Icons.currency_rupee_outlined),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.inventoryColor),
                  child:
                      Text(_isEditing ? 'Update Item' : 'Add Item'),
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
