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

    // BÚSQUEDA SEGURA CON TIPADO FUERTE
    Map<String, dynamic>? itemResult;
    for (final item in historyState.historyList) {
      if (item['id'] == itemId) {
        itemResult = item;
        break;
      }
    }
    
    if (itemResult == null) return const SizedBox();

    final isIncomeResult = itemResult['isIncome'] ?? false;
    final double amount = (itemResult['money'] as num).toDouble();
    final String month = itemResult['month'] ?? '';
    final int year = itemResult['year'] ?? 0;
    final String typeStr = itemResult['type'] ?? 'expense';
    final String? ticketId = itemResult['ticketId']; // Capturamos el ticketId si existe

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
          
          AppDialogs.dialogMessage(
            'Esta acción no se puede deshacer.\n¿Estás seguro de que quieres borrar este registro del historial?', 
            colorScheme
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
                    // Construimos el objeto Movement para el caso de uso
                    final movement = Movement(
                      id: itemId,
                      name: itemResult!['name'] ?? '',
                      amount: amount,
                      type: typeStr == 'income' ? MovementType.income : MovementType.expense,
                      isIncome: isIncomeResult,
                      date: itemResult['currentDate'] ?? '',
                      hour: itemResult['currentHour'] ?? '',
                      month: month,
                      year: year,
                      createdAt: DateTime.parse(itemResult['createdAt']),
                      ticketId: ticketId, // Pasamos el ticketId para que se pueda desmarcar
                    );

                    // Ejecutamos el caso de uso
                    await getIt<DeleteMovementUseCase>().call(movement);
                    
                    if (context.mounted) {
                      // 1. Refrescamos historial
                      context.read<HistoryCubit>().loadHistoryByDate(month, year);
                      
                      // 2. Refrescamos tickets si había uno asociado
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
