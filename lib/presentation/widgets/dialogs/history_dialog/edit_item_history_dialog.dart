import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/update_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
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
    final String month = itemResult['month'] ?? '';
    final int year = itemResult['year'] ?? 0;
    final String typeStr = itemResult['type'] ?? 'expense';

    return CustomDialogWrapper(
      borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
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
              Text(
                isIncomeResult ? 'EDITAR INGRESO' : 'EDITAR GASTO', 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w800, 
                  color: colorScheme.onSurface.withValues(alpha: 0.7), 
                  letterSpacing: 1.5
                )
              ),
            ],
          ),
          const SizedBox(height: 30),
          CustomInputTextWidget(
            controller: _nameController, 
            label: 'Nuevo concepto', 
            onChanged: historyCubit.newNameChanged, 
            errorText: historyState.newName.isPure ? null : historyState.newName.errorMessage, 
            textInputType: TextInputType.name
          ),
          const SizedBox(height: 15),
          CustomInputTextWidget(
            controller: _moneyController, 
            label: 'Nuevo importe', 
            onChanged: historyCubit.newMoneyChanged, 
            errorText: historyState.newMoney.isPure ? null : historyState.newMoney.errorMessage, 
            textInputType: const TextInputType.numberWithOptions(decimal: true)
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.pop(), 
                  child: Text(
                    'CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1
                    )
                  )
                )
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'ACTUALIZAR',
                  color: colorScheme.primary,
                  onPressed: (historyState.isValid && !_isLoading) 
                    ? () async {
                        setState(() => _isLoading = true);
                        try {
                          final String finalName = historyState.newName.value;
                          final double finalAmount = double.parse(historyState.newMoney.value.replaceAll(',', '.'));

                          final movement = Movement(
                            id: widget.itemId,
                            name: finalName,
                            amount: finalAmount,
                            type: typeStr == 'income' ? MovementType.income : MovementType.expense,
                            isIncome: isIncomeResult,
                            date: itemResult!['currentDate'] ?? '',
                            hour: itemResult['currentHour'] ?? '',
                            month: month,
                            year: year,
                            createdAt: DateTime.parse(itemResult['createdAt']),
                          );

                          await getIt<UpdateMovementUseCase>().call(movement, oldAmount);
                          
                          if (context.mounted) {
                            historyCubit.loadHistoryByDate(month, year);
                            historyCubit.resetCubit();
                            context.pop();
                          }
                        } catch (e) {
                          if (mounted) setState(() => _isLoading = false);
                        }
                    } : () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
