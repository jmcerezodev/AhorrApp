import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditSavingDialog extends StatefulWidget {
  final String savingId;
  const EditSavingDialog({super.key, required this.savingId});

  @override
  State<EditSavingDialog> createState() => _EditSavingDialogState();
}

class _EditSavingDialogState extends State<EditSavingDialog> {
  String newValue = '';
  bool isValid = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final appwriteRepo = AppwriteRepository();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? item;
    for (final s in historyState.historyList) {
      if (s['id'] == widget.savingId) {
        item = s;
        break;
      }
    }
    
    if (item == null) return const SizedBox();

    final double oldAmount = (item['money'] as num).toDouble();
    final bool isWithdrawal = oldAmount < 0; // Si es negativo, es una retirada

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), 
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), 
                  child: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 24)
                ),
                const SizedBox(width: 15),
                Text(
                  isWithdrawal ? 'EDITAR RETIRADA' : 'EDITAR APORTACIÓN', 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)
                ),
              ],
            ),
            const SizedBox(height: 30),
            CustomInputTextWidget(
              label: isWithdrawal ? 'Nuevo importe de retirada' : 'Nuevo importe de ahorro', 
              hintText: oldAmount.abs().toString(), // Mostramos siempre positivo para el usuario
              onChanged: (value) { 
                setState(() { 
                  newValue = value; 
                  isValid = double.tryParse(value.replaceAll(',', '.')) != null; 
                }); 
              }, 
              autoFocus: true, 
              enabled: !_isLoading,
              textInputType: const TextInputType.numberWithOptions(decimal: true)
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.pop(), 
                    child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1))
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (isValid && !_isLoading) ? () async {
                      setState(() => _isLoading = true);
                      try {
                        final double? inputMoney = double.tryParse(newValue.replaceAll(',', '.'));
                        if (inputMoney != null) {
                          // Si era una retirada, el nuevo valor también debe ser negativo internamente
                          final double money = isWithdrawal ? -inputMoney : inputMoney;

                          // 1. Actualizar en Appwrite (Nube)
                          await appwriteRepo.updateSaving(documentId: widget.savingId, money: money);
                          
                          if (mounted) {
                            // 2. Sincronizar localmente (Isar)
                            await context.read<HistoryCubit>().updateMovementLocally(
                              LocalHistory()
                                ..appwriteId = widget.savingId
                                ..name = isWithdrawal ? 'Retirada de ahorros' : 'Aportación de ahorro'
                                ..money = money
                                ..type = 'saving'
                                ..isIncome = false
                                ..currentDate = item!['currentDate'] ?? ''
                                ..currentHour = item['currentHour'] ?? ''
                                ..month = item['month'] ?? ''
                                ..year = item['year'] ?? 0
                                ..createdAt = DateTime.parse(item['createdAt']),
                              oldAmount
                            );
                            
                            // 3. Refrescar contador de ahorros
                            await context.read<SavingsCubit>().loadSavings();
                            
                            if (mounted) context.pop();
                          }
                        }
                      } catch (e) {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 15), 
                      elevation: 0, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: _isLoading 
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

class DeleteSavingItemDialog extends StatelessWidget {
  final String savingId;
  const DeleteSavingItemDialog({super.key, required this.savingId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyCubit = context.watch<HistoryCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? item;
    for (final s in historyCubit.state.historyList) {
      if (s['id'] == savingId) {
        item = s;
        break;
      }
    }
    
    if (item == null) return const SizedBox();
    
    final double amount = (item['money'] as num).toDouble();
    final bool isWithdrawal = amount < 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade400.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isWithdrawal ? Icons.undo_rounded : Icons.delete_sweep_rounded, color: Colors.red.shade400, size: 32)),
            const SizedBox(height: 20),
            Text(
              isWithdrawal ? '¿ELIMINAR RETIRADA?' : '¿ELIMINAR APORTACIÓN?', 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)
            ),
            const SizedBox(height: 15),
            Text(
              isWithdrawal 
                ? 'Al eliminar esta retirada, el dinero se sumará de nuevo a tus ahorros totales.' 
                : 'Esta aportación se restará de tus ahorros totales y se borrará del historial.', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5)
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => context.pop(), child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1)))),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. Borrar de Appwrite y Local (SavingsCubit gestiona el total)
                      await context.read<SavingsCubit>().removeContribution(savingId);
                      
                      if (context.mounted) {
                        // 2. Refrescar historial instantáneo (HistoryCubit)
                        await historyCubit.deleteMovementLocally(
                          savingId, 
                          item!['month'] ?? '', 
                          item['year'] ?? 0, 
                          amount, 
                          'saving'
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
