import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:ahorrapp/presentation/bloc/date_cubit/date_cubit.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/add_edit_ticket_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/view_ticket_image_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TicketItemCard extends StatelessWidget {
  final TicketItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const TicketItemCard({
    super.key,
    required this.item,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPress: () => _showEditDialog(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.isTransferred 
              ? Colors.green.withValues(alpha: 0.2) 
              : Colors.orange.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // 1. BOTÓN AÑADIR A GASTOS (En lugar de miniatura)
              _AddExpenseButton(item: item),
              
              const SizedBox(width: 12),

              // 2. INFO DEL TICKET
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: colorScheme.onSurface,
                        decoration: item.isTransferred ? TextDecoration.lineThrough : null,
                        decorationColor: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded, 
                          size: 10, 
                          color: colorScheme.onSurface.withValues(alpha: 0.4)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(item.date),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: item.isTransferred 
                              ? Colors.green.withValues(alpha: 0.7) 
                              : Colors.orange.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 3. TOTAL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${humanizeNumbers.number(item.amount)}€',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: item.isTransferred 
                        ? Colors.green.shade700 
                        : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (item.imagePath != null && File(item.imagePath!).existsSync()) {
      showDialog(
        context: context,
        builder: (_) => ViewTicketImageDialog(
          imagePath: item.imagePath!,
          title: item.name,
        ),
      );
    } else {
      _showEditDialog(context);
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditTicketItemDialog(item: item),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  final TicketItem item;
  const _AddExpenseButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isTransferred = item.isTransferred;

    return Container(
      decoration: BoxDecoration(
        color: isTransferred 
          ? Colors.green.withValues(alpha: 0.1) 
          : Colors.orange.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isTransferred ? null : () => _addTicketToExpenses(context),
        icon: Icon(
          isTransferred ? Icons.check_circle_rounded : Icons.add_task_rounded,
          color: isTransferred ? Colors.green : Colors.orange,
          size: 22,
        ),
        tooltip: isTransferred ? 'Ticket ya añadido' : 'Añadir a gastos',
      ),
    );
  }

  Future<void> _addTicketToExpenses(BuildContext context) async {
    final ticketsCubit = context.read<TicketsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final dateCubit = context.read<DateCubit>();
    final navigator = Navigator.of(context);

    try {
      await getIt<TransferTicketsToExpensesUseCase>().call(
        userId: Preferences.uId,
        items: [item],
        asPack: false,
      );

      // Marcamos como transferido en lugar de eliminar
      await ticketsCubit.updateItem(item.copyWith(isTransferred: true));

      // Recargamos historial de gastos
      final dateState = dateCubit.state;
      historyCubit.loadHistoryByDate(dateState.month, dateState.year);

      if (navigator.mounted) {
        showDialog(
          context: navigator.context,
          builder: (_) => SuccessfulDialogNoGo(
            title: '¡AÑADIDO!',
            sucessfulName: 'El ticket de "${item.name}" se ha añadido a tus gastos.',
          ),
        );
      }
    } catch (e) {
      if (navigator.mounted) {
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir gasto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
