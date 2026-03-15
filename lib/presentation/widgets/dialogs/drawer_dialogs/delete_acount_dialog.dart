import 'package:ahorrapp/core/config/responsive_utils.dart';
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
      horizontalInsetPadding: 30.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            customIcon: isSubmitting 
              ? SizedBox(width: 32.w, height: 32.w, child: const CircularProgressIndicator(color: Colors.red, strokeWidth: 3))
              : null,
            icon: Icons.no_accounts_rounded, 
            color: Colors.red.shade400, 
            title: '¿Eliminar Cuenta?',
            colorScheme: colorScheme,
          ),
          SizedBox(height: 20.h),
          
          if (isSubmitting)
            AppDialogs.dialogMessage('Eliminando tus datos de forma segura...', colorScheme)
          else ...[
            AppDialogs.dialogMessage(
              'Estás a punto de eliminar permanentemente tu cuenta y todos tus datos.',
              colorScheme,
            ),
            SizedBox(height: 10.h),
            AppDialogs.dialogMessage(
              'Esta acción no se puede deshacer.',
              colorScheme,
              customColor: Colors.red.shade400.withValues(alpha: 0.8),
            ),
          ],
          
          SizedBox(height: 25.h),

          if (!isSubmitting)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: CustomInputTextWidget(
                  prefixIcon: Icons.key_rounded,
                  label: 'CONTRASEÑA PARA CONFIRMAR',
                  hintText: 'Tu contraseña',
                  onChanged: deleteAcountCubit.inputValueDeleteAcount,
                  autoFocus: false,
                  obscureText: true,
                  textInputType: TextInputType.name,
                  textCapitalization: TextCapitalization.none,
                ),
              ),
            ),

          if (isSubmitting) ...[
            SizedBox(height: 10.h),
            LinearProgressIndicator(
              value: state.deleteProgress,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(10.w),
              minHeight: 8.h,
            ),
            SizedBox(height: 10.h),
            Text(
              '${(state.deleteProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12.sp, 
                fontWeight: FontWeight.w900, 
                color: Colors.red.shade400,
                letterSpacing: 1,
              ),
            ),
          ],

          SizedBox(height: 30.h),

          if (!isSubmitting)
            OverflowBar(
              spacing: 15.w,
              overflowSpacing: 10.h,
              alignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                  child: AppDialogs.dialogSecondaryButton(
                    text: 'CANCELAR', 
                    onPressed: () => context.pop(), 
                    colorScheme: colorScheme
                  ),
                ),
                SizedBox(
                  width: 120.w,
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
