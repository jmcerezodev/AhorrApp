import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteAcountDialog extends StatefulWidget {
  final String title;
  final String text;
  
  const DeleteAcountDialog({
    super.key, 
    required this.title, 
    required this.text,
  });

  @override
  State<DeleteAcountDialog> createState() => _DeleteAcountDialogState();
}

class _DeleteAcountDialogState extends State<DeleteAcountDialog> {
  @override
  Widget build(BuildContext context) {
    final deleteAcountCubit = context.watch<DeleteAcountCubit>();
    final state = deleteAcountCubit.state;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSubmitting = state.status == DeleteAccountStatus.submitting;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4), 
            width: 1.5
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade400.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isSubmitting 
                ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 3))
                : Icon(Icons.no_accounts_rounded, color: Colors.red.shade400, size: 32),
            ),
            const SizedBox(height: 20),
            
            Text(
              widget.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            
            Text(
              isSubmitting ? 'Eliminando tus datos de forma segura...' : widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            if (!isSubmitting)
              CustomInputTextWidget(
                prefixIcon: Icons.key_rounded,
                label: 'Contraseña para confirmar',
                hintText: 'Tu contraseña',
                onChanged: deleteAcountCubit.inputValueDeleteAcount,
                autoFocus: false,
                obscureText: true,
                textInputType: TextInputType.name,
                textCapitalization: TextCapitalization.none,
              ),

            if (isSubmitting) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: state.deleteProgress,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 10),
              Text(
                '${(state.deleteProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.red.shade400
                ),
              ),
            ],

            const SizedBox(height: 30),

            if (!isSubmitting)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: Text(
                        'CANCELAR', 
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4), 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.deleteAcountValueInput != Preferences.password
                      ? null 
                      : () => deleteAcountCubit.onSubmit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
