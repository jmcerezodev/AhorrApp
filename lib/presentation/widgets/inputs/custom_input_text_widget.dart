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
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? onPressedSuffixIcon;
  final TextInputType? textInputType;
  final TextCapitalization textCapitalization;
  final bool enableInteractiveSelection;
  final FocusNode? focusNode;

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
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputType,
    this.onPressedSuffixIcon,
    this.textCapitalization = TextCapitalization.sentences,
    this.enableInteractiveSelection = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Colors.orange;
    final theme = Theme.of(context);
    
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );

    return Theme(
      data: theme.copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryColor,
          selectionColor: Color(0x4DFF9800),
          selectionHandleColor: primaryColor,
        ),
      ),
      child: TextFormField(
        // Añadimos una key única basada en el label para asegurar reconstrucción y gestos limpios
        key: label != null ? Key('input_${label!.toLowerCase().replaceAll(' ', '_')}') : null,
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        initialValue: controller == null ? initialValue : null,
        validator: validator,
        autofocus: autoFocus,
        enabled: enabled,
        textCapitalization: textCapitalization,
        keyboardType: textInputType,
        obscureText: obscureText,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: materialTextSelectionControls, 
        style: const TextStyle(fontSize: 15), 
        decoration: InputDecoration(
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: primaryColor, width: 2)
          ),
          errorBorder: border.copyWith(borderSide: BorderSide(color: Colors.red.shade800)),
          focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: Colors.red.shade800, width: 2)),
          disabledBorder: border.copyWith(borderSide: BorderSide(color: Colors.grey.shade200)),
    
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          label: label != null ? Text(label!) : null,
          labelStyle: TextStyle(color: enabled ? Colors.grey.shade600 : Colors.grey.shade400),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: enabled ? Colors.blueGrey.shade400 : Colors.grey.shade300) : null,
          suffixIcon: suffixIcon != null 
            ? IconButton(
                onPressed: enabled ? onPressedSuffixIcon : null, 
                icon: Icon(suffixIcon, color: enabled ? Colors.blueGrey.shade400 : Colors.grey.shade300, size: 22),
              ) 
            : null,
          errorText: errorText, 
        ),
      ),
    );
  }
}
