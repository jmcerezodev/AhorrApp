import 'package:ahorrapp/core/appwrite/appwrite_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/authenticaction_cubits/update_name/update_name_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/error_dialog.dart';
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), 
            width: 1.5
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.badge_outlined, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 15),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Nuevo Nombre',
              hintText: updateNameCubit.state.name, // Usamos el nombre del cubit
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
                  child: ElevatedButton(
                    onPressed: updateNameCubit.state.isValid && updateNameCubit.state.formStatus != FormStatusUpdateName.validating ? () async {
                      try {
                        updateNameCubit.onSubmit();
                        final newName = updateNameCubit.state.newName.value;
                        await AppwriteService().account.updateName(name: newName);
                        
                        // Sincronizamos preferencias y el Cubit para el Home
                        Preferences.name = newName;
                        updateNameCubit.onUpdateSuccess(newName);
                        
                        if (context.mounted) {
                          context.pop();
                          showDialog(
                            context: context,
                            builder: (context) => const SuccessfulDialogNoGo(sucessfulName: 'Nombre actualizado correctamente'),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => const ErrorDialog(errorMessage: 'No se pudo actualizar el nombre'),
                          );
                        }
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: updateNameCubit.state.formStatus == FormStatusUpdateName.validating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ACTUALIZAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
