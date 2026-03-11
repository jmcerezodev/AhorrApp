import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/delete_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: isWithdrawal ? Icons.undo_rounded : Icons.delete_sweep_rounded, 
            color: Colors.red.shade400, 
            title: isWithdrawal ? '¿ELIMINAR RETIRADA?' : '¿ELIMINAR APORTACIÓN?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                if (isWithdrawal) ...[
                  const TextSpan(text: 'Al eliminar esta '),
                  const TextSpan(text: 'retirada', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const TextSpan(text: ', el dinero se sumará de nuevo a tus '),
                  const TextSpan(text: 'ahorros totales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const TextSpan(text: '.'),
                ] else ...[
                  const TextSpan(text: 'Esta '),
                  const TextSpan(text: 'aportación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const TextSpan(text: ' se restará de tus '),
                  const TextSpan(text: 'ahorros totales', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const TextSpan(text: ' y se borrará del historial.'),
                ],
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
                  text: 'ELIMINAR', 
                  color: Colors.red.shade400,
                  onPressed: () async {
                    final movement = Movement(
                      id: savingId,
                      name: item!['name'] ?? (isWithdrawal ? 'Retirada de ahorros' : 'Aportación de ahorro'),
                      amount: amount,
                      type: MovementType.saving,
                      isIncome: false,
                      date: item['currentDate'] ?? '',
                      hour: item['currentHour'] ?? '',
                      month: item['month'] ?? '',
                      year: item['year'] ?? 0,
                      createdAt: DateTime.parse(item['createdAt']),
                      isSpent: item['isSpent'] ?? false,
                    );

                    await getIt<DeleteMovementUseCase>().call(movement);
                    
                    if (context.mounted) {
                      context.read<HistoryCubit>().loadHistoryByDate(item['month'], item['year']);
                      context.read<SavingsCubit>().loadSavings();
                      context.pop();
                    }
                  }, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
