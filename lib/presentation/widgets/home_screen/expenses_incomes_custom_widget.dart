import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/singletons/global_variables_singleton.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ExpensesIncomesCustomWidget extends StatelessWidget {
  const ExpensesIncomesCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sigleton = Singleton();
    final humanizeNumbers = HumanizeNumbers();
    final date = Date();
    final filterLists = FilterLists();
  
    final historyCubit = context.watch<HistoryCubit>().state;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FadeInLeft(
              child: _CompactActionCard(
                title: 'INGRESOS',
                money: (historyCubit.historyList.isNotEmpty) ? humanizeNumbers.number(filterLists.totalIncome(context, historyCubit.historyList)) : '0',
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.green.shade600,
                bgColor: Colors.green.shade50,
                borderColor: Colors.green.shade100,
                glowColor: Colors.green.shade100,
                onPressed: () {
                  // Cerramos el calendario si está abierto para evitar overflow con el teclado
                  context.read<DateCubit>().isOpen(false);
                  
                  if ((sigleton.currentDate['month'] == date.monthNames() && (sigleton.currentDate['year'] == date.year()))) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const IncomesDialog(),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ErrorDateDialog(textDialog: 'No puedes añadir ingresos \nen una fecha diferente a la actual'),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FadeInRight(
              child: _CompactActionCard(
                title: 'GASTOS',
                money: (historyCubit.historyList.isNotEmpty) ? humanizeNumbers.number(filterLists.totalExpense(context, historyCubit.historyList)) : '0',
                icon: Icons.arrow_downward_rounded,
                iconColor: Colors.red.shade600,
                bgColor: Colors.red.shade50,
                borderColor: Colors.red.shade100,
                glowColor: Colors.red.shade100,
                onPressed: () {
                  // Cerramos el calendario si está abierto para evitar overflow con el teclado
                  context.read<DateCubit>().isOpen(false);

                  if ((sigleton.currentDate['month'] == date.monthNames() && (sigleton.currentDate['year'] == date.year()))) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ExpensesDialog(),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ErrorDateDialog(
                        textDialog: 'No puedes añadir gastos \nen una fecha diferente a la actual',
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactActionCard extends StatelessWidget {
  final String title;
  final String money;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color glowColor;
  final VoidCallback onPressed;

  const _CompactActionCard({
    required this.title,
    required this.money,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.glowColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$money€',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
