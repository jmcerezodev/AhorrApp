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
            title: isIncomeResult ? '¿Eliminar Ingreso?' : '¿Eliminar Gasto?',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          AppDialogs.dialogMessage(
            '¿Estás seguro de que quieres borrar este registro de tu historial?',
            colorScheme,
          ),
          const SizedBox(height: 10),
          Text(
            '"$itemName"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          AppDialogs.dialogMessage(
            'Esta acción no se puede deshacer.',
            colorScheme,
            customColor: Colors.red.shade400.withValues(alpha: 0.8),
          ),
          
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(),
                  colorScheme: colorScheme,
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
