import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/ticket_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsHistoryWidget extends StatelessWidget {
  const TicketsHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        final items = state.filteredItems;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.searchQuery.isEmpty ? Icons.receipt_long_outlined : Icons.search_off_rounded,
                  size: 80,
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  state.searchQuery.isEmpty ? 'SIN TICKETS' : 'SIN RESULTADOS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) => context.read<TicketsCubit>().reorderItems(oldIndex, newIndex),
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              key: ValueKey(item.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: TicketItemCard(
                item: item,
                humanizeNumbers: humanizeNumbers,
                colorScheme: colorScheme,
                isDark: isDark,
              ),
            );
          },
        );
      },
    );
  }
}
