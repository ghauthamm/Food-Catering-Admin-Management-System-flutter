import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

/// Reusable styled text form field.
class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.onSaved,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.initialValue,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSaved: onSaved,
      readOnly: readOnly,
      onTap: onTap,
      enabled: enabled,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

/// Styled dropdown field that matches [CustomTextField] look.
class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

/// Date picker field
class DatePickerField extends StatelessWidget {
  final String label;
  final String selectedDate;
  final void Function(String) onDateSelected;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      controller: TextEditingController(text: selectedDate),
      readOnly: true,
      suffixIcon: const Icon(Icons.calendar_today_outlined,
          color: AppTheme.primary, size: 20),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: AppTheme.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateSelected(picked.toIso8601String().split('T').first);
        }
      },
    );
  }
}
