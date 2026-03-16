import 'package:ahorrapp/core/config/app_input_styles.dart';
import 'package:flutter/material.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';

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
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;

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
    this.hintStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      style: TextStyle(
        fontSize: 15.sp, 
        fontWeight: FontWeight.w600,
        color: enabled ? null : Colors.grey,
      ),
      decoration: AppInputStyles.decoration(
        labelText: label ?? '',
        hintText: hintText ?? '',
        prefixIcon: prefixIcon,
        errorText: errorText,
        suffixIcon: suffixIcon != null 
          ? IconButton(
              onPressed: enabled ? onPressedSuffixIcon : null, 
              icon: Icon(suffixIcon, color: enabled ? Colors.blueGrey.shade400 : Colors.grey.shade300, size: Responsive.isSmallScreen ? 18.w : 22.w),
            ) 
          : null,
      ),
    );
  }
}
