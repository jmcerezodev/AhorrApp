import 'dart:async';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ConfirmShoppingTransferDialog extends StatefulWidget {
  final String message;

  const ConfirmShoppingTransferDialog({
    super.key,
    required this.message,
  });

  @override
  State<ConfirmShoppingTransferDialog> createState() => _ConfirmShoppingTransferDialogState();
}

class _ConfirmShoppingTransferDialogState extends State<ConfirmShoppingTransferDialog> {
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZoomIn(
          child: AppDialogs.dialogHeader(
            icon: Icons.check_rounded, 
            color: Colors.green, 
            title: '¡AÑADIDO CON ÉXITO!',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
        ),
        
        const SizedBox(height: 15),
        
        AppDialogs.dialogMessage(widget.message, colorScheme),
        
        const SizedBox(height: 30),

        AppDialogs.dialogPrimaryButton(
          text: 'ENTENDIDO', 
          onPressed: () => Navigator.of(context).pop(), 
          color: Colors.green
        ),
      ],
    );
  }
}
