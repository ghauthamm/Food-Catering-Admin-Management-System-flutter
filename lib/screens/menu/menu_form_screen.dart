import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Create or Edit a day-wise menu with dynamic item rows.
class MenuFormScreen extends StatefulWidget {
  final DayMenu? existingMenu;
  const MenuFormScreen({super.key, this.existingMenu});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDay = weekDays.first;
  String _selectedMealType = 'lunch';
  List<_MenuItemRow> _items = [];
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.existingMenu != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateForm();
    } else {
      _addItem();
    }
  }

  void _populateForm() {
    final m = widget.existingMenu!;
    _selectedDay = weekDays.contains(m.day) ? m.day : weekDays.first;
    _selectedMealType = m.mealType;
    _isActive = m.isActive;
    _items = m.items
        .map((i) => _MenuItemRow(
              nameCtrl: TextEditingController(text: i.name),
              priceCtrl: TextEditingController(text: i.price.toString()),
              category: i.category,
            ))
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    for (final row in _items) {
      row.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_MenuItemRow());
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      AppHelpers.showError(context, 'Please add at least one menu item');
      return;
    }

    setState(() => _isLoading = true);
    final provider = context.read<MenuProvider>();

    final items = _items
        .map((row) => MenuItem(
              name: row.nameCtrl.text.trim(),
              price: double.tryParse(row.priceCtrl.text) ?? 0,
              category: row.category,
            ))
        .toList();

    bool success;
    if (_isEditing) {
      final updated = widget.existingMenu!.copyWith(
        day: _selectedDay,
        mealType: _selectedMealType,
        items: items,
        isActive: _isActive,
        lastUpdated: DateTime.now().toIso8601String().split('T').first,
      );
      success = await provider.updateMenu(updated);
    } else {
      success = await provider.addMenu(
        day: _selectedDay,
        mealType: _selectedMealType,
        items: items,
        isActive: _isActive,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Menu updated!' : 'Menu created!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save menu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Menu' : 'New Day Menu'),
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
                      // ─── Day Selection ─────────────────────────────────────
                      CustomDropdownField<String>(
                        label: 'Day of Week *',
                        value: _selectedDay,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        items: weekDays
                            .map((day) => DropdownMenuItem(
                                  value: day,
                                  child: Text(day),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedDay = value);
                        },
                        validator: (v) => v == null ? 'Select a day' : null,
                      ),
                      const SizedBox(height: 16),

                      // ─── Meal Type Selection ──────────────────────────────
                      CustomDropdownField<String>(
                        label: 'Meal Type *',
                        value: _selectedMealType,
                        prefixIcon:
                            const Icon(Icons.restaurant_menu_outlined),
                        items: const [
                          DropdownMenuItem(
                              value: 'breakfast', child: Text('Breakfast')),
                          DropdownMenuItem(
                              value: 'lunch', child: Text('Lunch')),
                          DropdownMenuItem(
                              value: 'dinner', child: Text('Dinner')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedMealType = value);
                        },
                        validator: (v) =>
                            v == null ? 'Select meal type' : null,
                      ),
                      const SizedBox(height: 16),

                      // ─── Active Toggle ────────────────────────────────────
                      SwitchListTile(
                        title: const Text('Active Menu'),
                        subtitle: Text(
                          _isActive
                              ? 'This menu will be available for orders'
                              : 'This menu is disabled',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: _isActive,
                        activeColor: AppTheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                      const SizedBox(height: 20),

                      // ─── Menu Items ───────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Menu Items',
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
                              child: Text('Price',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Category',
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
                        (i) => _MenuItemRowWidget(
                          key: ValueKey(i),
                          row: _items[i],
                          onRemove: () => _removeItem(i),
                          onChanged: () => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ─── Submit ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    _isEditing ? 'Update Menu' : 'Create Menu',
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

// ─── Menu Item Row Model ──────────────────────────────────────────────────────

class _MenuItemRow {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  String? category;

  _MenuItemRow({
    TextEditingController? nameCtrl,
    TextEditingController? priceCtrl,
    this.category,
  })  : nameCtrl = nameCtrl ?? TextEditingController(),
        priceCtrl = priceCtrl ?? TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }
}

// ─── Menu Item Row Widget ─────────────────────────────────────────────────────

class _MenuItemRowWidget extends StatelessWidget {
  final _MenuItemRow row;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _MenuItemRowWidget({
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
                hintText: 'e.g. Paneer Tikka',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
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
                hintText: '120',
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
          const SizedBox(width: 6),

          // Category dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: row.category,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              ),
              hint: const Text('Cat', style: TextStyle(fontSize: 12)),
              items: menuCategories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (v) {
                row.category = v;
                onChanged();
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
