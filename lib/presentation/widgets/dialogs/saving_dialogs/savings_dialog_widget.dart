import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_empty_dialog_widget.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavingsDialog extends StatefulWidget {
  const SavingsDialog({super.key});

  @override
  State<SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends State<SavingsDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = Date();
    final AppwriteRepository appwriteRepo = AppwriteRepository();
    final savingsCubit = context.watch<SavingsCubit>();
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.savings_outlined, color: colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'AÑADIR AHORRO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isLoading ? null : () {
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (context) => const SavingsDeleteDialog(),
                    );
                  },
                  icon: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade300, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Cantidad a ahorrar',
              hintText: '0.00',
              onChanged: savingsCubit.savingChanged,
              errorText: savingsCubit.state.saving.isPure ? null : savingsCubit.state.saving.errorMessage,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
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
                    onPressed: (savingsCubit.state.isValid && !_isLoading)
                    ? () async {
                        setState(() => _isLoading = true);
                        try {
                          final double amount = double.parse(savingsCubit.state.saving.value.replaceAll(',', '.'));
                          final String monthName = date.monthNames();
                          final int yearInt = int.parse(date.year());

                          // 1. Guardar en Appwrite
                          final doc = await appwriteRepo.addSaving(
                            userId: Preferences.uId,
                            money: amount,
                            month: monthName,
                            year: yearInt,
                          );

                          // 2. Sincronizar con Isar y refrescar historial
                          if (mounted) {
                            final historyCubit = context.read<HistoryCubit>();
                            await historyCubit.addMovementLocally(
                              LocalHistory()
                                ..appwriteId = doc.$id
                                ..name = 'Aportación de ahorro'
                                ..money = amount
                                ..type = 'saving'
                                ..isIncome = false
                                ..currentDate = date.currentDate()
                                ..currentHour = date.currentHour()
                                ..month = monthName
                                ..year = yearInt
                                ..createdAt = DateTime.parse(doc.$createdAt)
                            );
                            
                            // 3. Refrescar contador de ahorros
                            await context.read<SavingsCubit>().loadSavings();
                            
                            if (mounted) context.pop();
                          }
                        } catch (e) {
                          print('Error al ahorrar: $e');
                          if (mounted) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error al conectar con el servidor. Inténtalo de nuevo.'))
                            );
                          }
                        }
                      }
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('AHORRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
