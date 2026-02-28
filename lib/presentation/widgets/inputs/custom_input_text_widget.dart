import 'package:flutter/material.dart';

class CustomInputTextWidget extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? initialValue;
  final String? Function(String?)? validator;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool? isDense;
  final bool obscureText;
  final bool autoFocus;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? onPressedSuffixIcon;
  final TextInputType? textInputType;
  final TextCapitalization textCapitalization;

  const CustomInputTextWidget({
    super.key,
    this.controller,
    this.onChanged, 
    this.initialValue,
    this.validator,
    this.label, 
    this.hintText, 
    this.errorText, 
    this.isDense,
    this.obscureText = false,
    this.autoFocus = true,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputType,
    this.onPressedSuffixIcon,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      initialValue: controller == null ? initialValue : null,
      validator: validator,
      autofocus: autoFocus,
      textCapitalization: textCapitalization,
      keyboardType: textInputType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15), // Tamaño de fuente profesional
      decoration: InputDecoration(
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: Colors.orange.shade300, width: 2)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: Colors.red.shade800)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: Colors.red.shade800)),

        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), // Relleno interno
        label: label != null ? Text(label!) : null,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blueGrey.shade400) : null,
        // Solo mostramos el suffixIcon si existe, evitando el espacio vacío
        suffixIcon: suffixIcon != null 
          ? IconButton(
              onPressed: onPressedSuffixIcon, 
              icon: Icon(suffixIcon, color: Colors.blueGrey.shade400, size: 22),
            ) 
          : null,
        errorText: errorText, 
      ),
    );
  }
}
