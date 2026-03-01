import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
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
  bool isValid = true; 
  bool _isLoading = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final historyCubit = context.read<HistoryCubit>();
    Map<String, dynamic>? item;
    
    // Buscamos el item en la lista actual del historial
    for (final s in historyCubit.state.historyList) {
      if (s['id'] == widget.savingId) {
        item = s;
        break;
      }
    }
    
    if (item != null) {
      final double amount = (item['money'] as num).toDouble().abs();
      newValue = amount.toString();
      _controller = TextEditingController(text: newValue);
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final appwriteRepo = getIt<AppwriteRepository>();
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
    final bool isWithdrawal = oldAmount < 0;

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
              controller: _controller,
              label: isWithdrawal ? 'Nuevo importe de retirada' : 'Nuevo importe de ahorro', 
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
                        final double? inputMoney = double.tryParse(_controller.text.replaceAll(',', '.'));
                        if (inputMoney != null) {
                          final double money = isWithdrawal ? -inputMoney : inputMoney;

                          // 1. Actualizar en Appwrite
                          await appwriteRepo.updateSaving(documentId: widget.savingId, money: money);
                          
                          if (mounted) {
                            // 2. Sincronizar localmente (usando la nueva tabla LocalSaving)
                            await context.read<HistoryCubit>().updateMovementLocally(
                              LocalSaving()
                                ..appwriteId = widget.savingId
                                ..userId = Preferences.uId
                                ..description = isWithdrawal ? 'Retirada de ahorros' : 'Aportación de ahorro'
                                ..money = money
                                ..month = item!['month'] ?? ''
                                ..year = item['year'] ?? 0
                                ..isSpent = item['isSpent'] ?? false
                                ..createdAt = DateTime.parse(item['createdAt']),
                              oldAmount
                            );
                            
                            // 3. Refrescar total de ahorros
                            await context.read<SavingsCubit>().loadSavings();
                            
                            if (mounted) context.pop();
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
                        }
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
