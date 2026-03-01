import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/client_model.dart';
import '../../providers/client_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

/// Add or Edit client form screen.
class ClientFormScreen extends StatefulWidget {
  final ClientModel? existingClient;
  const ClientFormScreen({super.key, this.existingClient});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  String _selectedType = 'Company';
  bool _isLoading = false;

  bool get _isEditing => widget.existingClient != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.existingClient!;
      _nameCtrl.text = c.name;
      _phoneCtrl.text = c.phone;
      _emailCtrl.text = c.email ?? '';
      _addressCtrl.text = c.address ?? '';
      _gstCtrl.text = c.gstNumber ?? '';
      _selectedType = c.type;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _gstCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<ClientProvider>();
    bool success;

    if (_isEditing) {
      final updated = widget.existingClient!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        gstNumber:
            _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
        type: _selectedType,
      );
      success = await provider.updateClient(updated);
    } else {
      success = await provider.addClient(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        type: _selectedType,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address:
            _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        gstNumber:
            _gstCtrl.text.trim().isEmpty ? null : _gstCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppHelpers.showSuccess(
          context, _isEditing ? 'Client updated!' : 'Client added!');
      Navigator.pop(context);
    } else {
      AppHelpers.showError(context, 'Failed to save client');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Client' : 'Add Client'),
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
                // ─── Client Type ─────────────────────────────────────────────
                CustomDropdownField<String>(
                  label: 'Client Type',
                  value: _selectedType,
                  prefixIcon: const Icon(Icons.category_outlined),
                  items: clientTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedType = v!),
                ),
                const SizedBox(height: 16),

                // ─── Name ────────────────────────────────────────────────────
                CustomTextField(
                  label: 'Client Name *',
                  hint: 'ABC Hostel',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.business_outlined),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Client name is required';
                    }
                    return null;
                  },
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
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (v.length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Email (optional) ─────────────────────────────────────────
                CustomTextField(
                  label: 'Email (Optional)',
                  hint: 'contact@hostel.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // ─── Address (optional) ───────────────────────────────────────
                CustomTextField(
                  label: 'Address (Optional)',
                  hint: '123 Main Street, City',
                  controller: _addressCtrl,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),

                // ─── GST Number (optional) ────────────────────────────────────
                CustomTextField(
                  label: 'GST Number (Optional)',
                  hint: '29ABCDE1234F2Z5',
                  controller: _gstCtrl,
                  prefixIcon: const Icon(Icons.receipt_outlined),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length != 15) {
                      return 'GST number must be 15 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ─── Submit ──────────────────────────────────────────────────
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isEditing ? 'Update Client' : 'Add Client'),
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
