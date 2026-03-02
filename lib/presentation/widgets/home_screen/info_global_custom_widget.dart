import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_goal_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoGlogalWidget extends StatelessWidget {
  const InfoGlogalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final totalMoneyState = context.watch<TotalMoneyCubit>().state;
    final savingsState = context.watch<SavingsCubit>().state;
    final humanizeNumbers = HumanizeNumbers();
    
    final bool isLoading = historyState.status == HistoryStatus.loading || historyState.isSyncing;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Lógica de celebración: ¿Se ha cumplido la meta?
    final bool isGoalMet = savingsState.progress >= 1.0 && savingsState.savingGoal > 0;

    // CORRECCIÓN DE LÓGICA:
    // totalMoneyState.totalMoney = Cartera (Ingresos - Gastos)
    // savingsState.savingTotal = Hucha (Ahorros acumulados)
    final double displayedBalance = totalMoneyState.isSavingsIncluded 
        ? (totalMoneyState.totalMoney + savingsState.savingTotal)
        : totalMoneyState.totalMoney;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            // PARTE IZQUIERDA: BALANCE TOTAL
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centrado horizontal
                children: [
                  Text(
                    totalMoneyState.isSavingsIncluded ? 'BALANCE TOTAL\n(CON AHORROS)' : 'BALANCE EN\nCARTERA',
                    textAlign: TextAlign.center, // Centrado interno de las líneas
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isLoading)
                    const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${humanizeNumbers.number(displayedBalance)}€',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // PARTE DERECHA: MIS AHORROS
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const SavingsDialog(),
                );
              },
              onLongPress: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => const SavingsGoalDialog(),
                );
              },
              child: Container(
                width: 120, 
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isGoalMet 
                    ? Colors.green.withValues(alpha: 0.05) 
                    : Colors.orange.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isGoalMet 
                      ? Colors.green.withValues(alpha: 0.2) 
                      : Colors.orange.withValues(alpha: 0.1)
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MIS AHORROS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: isGoalMet ? Colors.green : Colors.orange,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isGoalMet) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check_circle, size: 10, color: Colors.green),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${humanizeNumbers.number(savingsState.savingTotal)}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isGoalMet ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // BARRA DE PROGRESO CON CAMBIO DE COLOR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: savingsState.progress,
                        minHeight: 4,
                        backgroundColor: (isGoalMet ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(isGoalMet ? Colors.green : Colors.orange),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Meta: ${humanizeNumbers.number(savingsState.savingGoal)}€',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isGoalMet 
                          ? Colors.green.withValues(alpha: 0.7) 
                          : Colors.orange.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
