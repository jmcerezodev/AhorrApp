import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditItemHistoryDialog extends StatefulWidget {
  final String itemId;
  const EditItemHistoryDialog({super.key, required this.itemId});

  @override
  State<EditItemHistoryDialog> createState() => _EditItemHistoryDialogState();
}

class _EditItemHistoryDialogState extends State<EditItemHistoryDialog> {
  bool _isLoading = false;
  late TextEditingController _nameController;
  late TextEditingController _moneyController;

  @override
  void initState() {
    super.initState();
    final historyCubit = context.read<HistoryCubit>();
    Map<String, dynamic>? item;
    for (final i in historyCubit.state.historyList) {
      if (i['id'] == widget.itemId) {
        item = i;
        break;
      }
    }

    if (item != null) {
      _nameController = TextEditingController(text: item['name']);
      _moneyController = TextEditingController(text: item['money'].toString());
      // Inicializamos el Cubit con los valores actuales para que el botón se active
      WidgetsBinding.instance.addPostFrameCallback((_) {
        historyCubit.newNameChanged(item!['name']);
        historyCubit.newMoneyChanged(item['money'].toString());
      });
    } else {
      _nameController = TextEditingController();
      _moneyController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appwriteRepo = getIt<AppwriteRepository>();
    final historyState = context.watch<HistoryCubit>().state;
    final historyCubit = context.read<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? itemResult;
    for (final item in historyState.historyList) {
      if (item['id'] == widget.itemId) {
        itemResult = item;
        break;
      }
    }
    if (itemResult == null) return const SizedBox();

    final isIncomeResult = itemResult['isIncome'] ?? false;
    final double oldAmount = (itemResult['money'] as num).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 15),
                Text(isIncomeResult ? 'EDITAR INGRESO' : 'EDITAR GASTO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: colorScheme.onSurface.withValues(alpha: 0.7), letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 30),
            CustomInputTextWidget(controller: _nameController, label: 'Nuevo concepto', onChanged: historyCubit.newNameChanged, errorText: historyState.newName.isPure ? null : historyState.newName.errorMessage, textInputType: TextInputType.name),
            const SizedBox(height: 15),
            CustomInputTextWidget(controller: _moneyController, label: 'Nuevo importe', onChanged: historyCubit.newMoneyChanged, errorText: historyState.newMoney.isPure ? null : historyState.newMoney.errorMessage, textInputType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: _isLoading ? null : () => context.pop(), child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1)))),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (historyState.isValid && !_isLoading) 
                    ? () async {
                        setState(() => _isLoading = true);
                        try {
                          final String finalName = historyState.newName.value;
                          final double finalAmount = double.parse(historyState.newMoney.value.replaceAll(',', '.'));

                          await appwriteRepo.updateHistory(documentId: widget.itemId, data: {'name': finalName, 'money': finalAmount});
                          
                          if (context.mounted) {
                            await historyCubit.updateMovementLocally(
                              LocalHistory()
                                ..appwriteId = widget.itemId
                                ..name = finalName
                                ..money = finalAmount
                                ..isIncome = isIncomeResult
                                ..type = isIncomeResult ? 'income' : 'expense'
                                ..currentDate = itemResult!['currentDate']
                                ..currentHour = itemResult['currentHour']
                                ..month = itemResult['month']
                                ..year = itemResult['year']
                                ..createdAt = DateTime.parse(itemResult['createdAt']),
                              oldAmount
                            );
                            historyCubit.resetCubit();
                            context.pop();
                          }
                        } catch (e) {
                          if (mounted) setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
                        }
                    } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
