import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoGlogalWidget extends StatelessWidget {
  const InfoGlogalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final filterLists = FilterLists();
    final savingsCubit = context.watch<SavingsCubit>().state;
    final historyCubit = context.watch<HistoryCubit>();
    final humanizeNumbers = HumanizeNumbers();

    final double totalMoneyResult = filterLists.calculateTotalMoney(context, historyCubit);

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          // Borde naranja sutil
          border: Border.all(
            color: Colors.orange.shade300.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              // Sombra con resplandor naranja muy suave
              color: Colors.orange.shade100.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BALANCE TOTAL',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${humanizeNumbers.number(totalMoneyResult)}€',
                        style: TextStyle(
                          color: Colors.blueGrey.shade900,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: _CompactSavingButton(
                  money: savingsCubit.savingTotal,
                  onTap: () => showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (dialogContext) => const SavingsDialog(),
                  ),
                  onLongPress: () {
                    if (savingsCubit.savingTotal > 0) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (dialogContext) => const SavingsDeleteDialog(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSavingButton extends StatelessWidget {
  final double money;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CompactSavingButton({
    required this.money,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orange.shade100, width: 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings_rounded, color: Colors.orange.shade700, size: 14),
                const SizedBox(width: 4),
                Text(
                  'AHORROS',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${humanizeNumbers.number(money)}€',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
