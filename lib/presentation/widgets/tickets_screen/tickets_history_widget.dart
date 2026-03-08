import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/add_edit_ticket_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/delete_ticket_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/ticket_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsHistoryWidget extends StatelessWidget {
  const TicketsHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Text(
            'PRODUCTOS DETECTADOS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 2.0,
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<TicketsCubit, TicketsState>(
            builder: (context, state) {
              if (state.status == TicketsStatus.loading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.items.isEmpty) {
                return _EmptyTicketsState(colorScheme: colorScheme);
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: state.items.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<TicketsCubit>().reorderItems(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _TicketItemDismissible(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    humanizeNumbers: humanizeNumbers,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TicketItemDismissible extends StatelessWidget {
  final TicketItem item;
  final int index;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _TicketItemDismissible({
    super.key,
    required this.item,
    required this.index,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key('ticket_dismiss_${item.id}'),
        background: const SwipeBackgroundWidget(
          color: Colors.green,
          icon: Icons.edit_note_rounded,
          label: 'EDITAR',
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: const SwipeBackgroundWidget(
          color: Colors.red,
          icon: Icons.delete_sweep_rounded,
          label: 'ELIMINAR',
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AddEditTicketItemDialog(item: item),
            );
            return false;
          } else {
            return await showDialog<bool>(
              context: context,
              builder: (context) => DeleteTicketItemDialog(
                itemId: item.id,
                itemName: item.name,
              ),
            );
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            context.read<TicketsCubit>().deleteItem(item.id);
          }
        },
        child: TicketItemCard(
          item: item,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _EmptyTicketsState extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptyTicketsState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 15),
          Text(
            'ESCANEADO VACÍO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Haz una foto a un ticket para empezar.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
