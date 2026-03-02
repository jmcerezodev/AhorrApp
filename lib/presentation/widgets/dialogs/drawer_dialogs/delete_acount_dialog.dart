import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = AuthAppwrite();
    final deleteAcountCubit = context.watch<DeleteAcountCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              child: _isLoading 
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
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            CustomInputTextWidget(
              prefixIcon: Icons.key_rounded,
              label: 'Contraseña para confirmar',
              hintText: 'Tu contraseña',
              onChanged: deleteAcountCubit.inputValueDeleteAcount,
              autoFocus: false,
              obscureText: true,
              enabled: !_isLoading,
              textInputType: TextInputType.name,
              textCapitalization: TextCapitalization.none,
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
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
                    onPressed: (_isLoading || deleteAcountCubit.state.deleteAcountValueInput != Preferences.password) 
                    ? null 
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                          await authService.deleteAcount(context);
                        } catch (e) {
                          if (mounted) setState(() => _isLoading = false);
                        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
