import 'dart:async';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmManualPaymentDialog extends StatefulWidget {
  final dynamic expense; 
  final String amount;

  const ConfirmManualPaymentDialog({
    super.key,
    required this.expense,
    required this.amount,
  });

  @override
  State<ConfirmManualPaymentDialog> createState() => _ConfirmManualPaymentDialogState();
}

class _ConfirmManualPaymentDialogState extends State<ConfirmManualPaymentDialog> {
  bool _isSuccess = false;
  Timer? _autoCloseTimer;

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isSuccess 
              ? Colors.green.withValues(alpha: isDark ? 0.3 : 0.5) 
              : Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4), 
            width: 1.5
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ICONO ANIMADO (ZoomIn)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isSuccess 
                ? ZoomIn(
                    child: Container(
                      key: const ValueKey('success_icon'),
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                    ),
                  )
                : Container(
                    key: const ValueKey('confirm_icon'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.add_task_rounded, color: Colors.orange, size: 32),
                  ),
            ),
            
            const SizedBox(height: 20),
            
            // TÍTULO
            Text(
              _isSuccess ? '¡ANOTADO CON ÉXITO!' : '¿ANOTAR GASTO AHORA?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _isSuccess ? Colors.green : colorScheme.onSurface,
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 15),
            
            // MENSAJE
            _isSuccess 
              ? Text(
                  'El gasto "${widget.expense.name}" se ha añadido a tu historial.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
                )
              : Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
                    children: [
                      const TextSpan(text: 'Se va a registrar un gasto de '),
                      TextSpan(text: '${widget.amount}€', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const TextSpan(text: ' bajo el nombre de '),
                      TextSpan(text: widget.expense.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      const TextSpan(text: ' en tu historial principal.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
            
            const SizedBox(height: 30),

            // BOTONES (Sin animación de entrada para el de cerrar)
            if (!_isSuccess)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('ACEPTAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('CERRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleAccept() {
    context.read<RecurrentExpensesCubit>().applyExpenseManually(widget.expense);
    setState(() => _isSuccess = true);
    
    _autoCloseTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isSuccess) {
        Navigator.of(context).pop(true);
      }
    });
  }
}
