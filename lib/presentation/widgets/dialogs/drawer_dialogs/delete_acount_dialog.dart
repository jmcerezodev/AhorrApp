import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
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

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            customIcon: isSubmitting 
              ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 3))
              : null,
            icon: Icons.no_accounts_rounded, 
            color: Colors.red.shade400, 
            title: widget.title.toUpperCase(),
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          AppDialogs.dialogMessage(
            isSubmitting ? 'Eliminando tus datos de forma segura...' : widget.text, 
            colorScheme
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
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'ELIMINAR', 
                    onPressed: state.deleteAcountValueInput != Preferences.password
                    ? null
                    : () => deleteAcountCubit.onSubmit(context), 
                    color: Colors.red.shade400
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
