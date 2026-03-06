import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_name/update_name_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateNameDialog extends StatelessWidget {
  final String title;
  
  const UpdateNameDialog({
    super.key, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final updateNameCubit = context.watch<UpdateNameCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<UpdateNameCubit, UpdateNameState>(
      listener: (context, state) {
        if (state.status == UpdateNameStatus.success) {
          context.pop();
          AppDialogs.showCustomDialog(
            context: context,
            builder: const SuccessfulDialogNoGo(sucessfulName: 'Nombre actualizado correctamente'),
          );
        } else if (state.status == UpdateNameStatus.failure) {
          AppDialogs.showCustomDialog(
            context: context,
            builder: ErrorDialog(errorMessage: state.errorMessage ?? 'No se pudo actualizar el nombre'),
          );
        }
      },
      child: CustomDialogWrapper(
        borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogRowHeader(
              icon: Icons.badge_outlined, 
              title: title, 
              color: colorScheme.primary, 
              colorScheme: colorScheme
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Nuevo Nombre',
              hintText: updateNameCubit.state.name,
              onChanged: updateNameCubit.newNameChanged,
              autoFocus: true,
              obscureText: false,
              textInputType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 30),

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
                    text: 'ACTUALIZAR',
                    color: colorScheme.primary,
                    isLoading: updateNameCubit.state.status == UpdateNameStatus.submitting,
                    onPressed: updateNameCubit.state.isValid && updateNameCubit.state.status != UpdateNameStatus.submitting ? () {
                      updateNameCubit.onSubmit();
                    } : () {},
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
