import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final int? maxLength;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      maxLength: maxLength,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffix,
        counterText: '',
      ),
    );
  }
}
