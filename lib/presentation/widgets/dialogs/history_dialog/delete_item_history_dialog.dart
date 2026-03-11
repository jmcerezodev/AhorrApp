import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/delete_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteItemHistoryDialog extends StatelessWidget {
  final String itemId;
  
  const DeleteItemHistoryDialog({
    super.key, 
    required this.itemId
  });

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? itemResult;
    for (final item in historyState.historyList) {
      if (item['id'] == itemId) {
        itemResult = item;
        break;
      }
    }
    
    if (itemResult == null) return const SizedBox();

    final isIncomeResult = itemResult['isIncome'] ?? false;
    final String itemName = itemResult['name'] ?? '';
    final double amount = (itemResult['money'] as num).toDouble();
    final String month = itemResult['month'] ?? '';
    final int year = itemResult['year'] ?? 0;
    final String typeStr = itemResult['type'] ?? 'expense';
    final String? ticketId = itemResult['ticketId'];

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.delete_outline_rounded, 
            color: Colors.red.shade400, 
            title: isIncomeResult ? '¿ELIMINAR INGRESO?' : '¿ELIMINAR GASTO?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                const TextSpan(text: '¿Estás seguro de que quieres borrar este '),
                TextSpan(text: isIncomeResult ? 'ingreso' : 'gasto', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                TextSpan(text: ' "$itemName"'),
                const TextSpan(text: ' del historial? Esta acción '),
                const TextSpan(text: 'no se puede deshacer.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            textAlign: TextAlign.center,
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
                  text: 'ELIMINAR', 
                  onPressed: () async {
                    final movement = Movement(
                      id: itemId,
                      name: itemName,
                      amount: amount,
                      type: typeStr == 'income' ? MovementType.income : MovementType.expense,
                      isIncome: isIncomeResult,
                      date: itemResult!['currentDate'] ?? '',
                      hour: itemResult['currentHour'] ?? '',
                      month: month,
                      year: year,
                      createdAt: DateTime.parse(itemResult['createdAt']),
                      ticketId: ticketId,
                    );

                    await getIt<DeleteMovementUseCase>().call(movement);
                    
                    if (context.mounted) {
                      context.read<HistoryCubit>().loadHistoryByDate(month, year);
                      if (ticketId != null) {
                        getIt<TicketsCubit>().loadItems();
                      }
                      context.pop();
                    }
                  }, 
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
