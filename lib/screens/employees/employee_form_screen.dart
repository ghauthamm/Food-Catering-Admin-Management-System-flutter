import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/employee_model.dart';
import '../../providers/employee_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Add or Edit employee form.
class EmployeeFormScreen extends StatefulWidget {
  final EmployeeModel? existingEmployee;
  const EmployeeFormScreen({super.key, this.existingEmployee});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  String _selectedRole = 'Cook';
  String _joinDate = AppHelpers.today();
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.existingEmployee != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.existingEmployee!;
      _nameCtrl.text = e.name;
      _phoneCtrl.text = e.phone;
      _wageCtrl.text = e.dailyWage.toString();
      _selectedRole = e.role;
      _joinDate = e.joinDate;
      _isActive = e.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _wageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<EmployeeProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.existingEmployee!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
        dailyWage: double.tryParse(_wageCtrl.text) ?? 0,
        joinDate: _joinDate,
        isActive: _isActive,
      );
      success = await provider.updateEmployee(updated);
    } else {
      success = await provider.addEmployee(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
        dailyWage: double.tryParse(_wageCtrl.text) ?? 0,
        joinDate: _joinDate,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Employee updated!' : 'Employee added!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Employee' : 'Add Employee'),
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
                // ─── Role ────────────────────────────────────────────────────
                CustomDropdownField<String>(
                  label: 'Role',
                  value: _selectedRole,
                  prefixIcon: const Icon(Icons.work_outline),
                  items: employeeRoles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),

                // ─── Name ────────────────────────────────────────────────────
                CustomTextField(
                  label: 'Full Name *',
                  hint: 'Rajesh Kumar',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // ─── Phone ───────────────────────────────────────────────────
                CustomTextField(
                  label: 'Phone Number *',
                  hint: '9876543210',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (v.length < 10) return 'Invalid phone';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Daily Wage ───────────────────────────────────────────────
                CustomTextField(
                  label: 'Daily Wage (₹) *',
                  hint: '500',
                  controller: _wageCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if ((double.tryParse(v) ?? 0) <= 0) return 'Enter valid wage';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Join Date ────────────────────────────────────────────────
                DatePickerField(
                  label: 'Joining Date',
                  selectedDate: _joinDate,
                  onDateSelected: (d) => setState(() => _joinDate = d),
                ),
                const SizedBox(height: 8),

                // ─── Active Status ────────────────────────────────────────────
                if (_isEditing)
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Active Employee'),
                    subtitle: const Text(
                        'Inactive employees can be hidden from lists'),
                    contentPadding: EdgeInsets.zero,
                  ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _submit,
                  child:
                      Text(_isEditing ? 'Update Employee' : 'Add Employee'),
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
