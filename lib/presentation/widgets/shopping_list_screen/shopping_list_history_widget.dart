import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/add_edit_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_empty_state.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingListHistoryWidget extends StatelessWidget {
  const ShoppingListHistoryWidget({super.key});

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
            'LISTA ACTUAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 2.0,
                ),
              ),
            ),
        Expanded(
          child: BlocBuilder<ShoppingListCubit, ShoppingState>(
            builder: (context, state) {
              if (state.status == ShoppingStatus.loading && state.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.items.isEmpty) {
                return ShoppingEmptyState(colorScheme: colorScheme);
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: state.items.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<ShoppingListCubit>().reorderItems(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _ShoppingItemDismissible(
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

class _ShoppingItemDismissible extends StatelessWidget {
  final ShoppingListItem item;
  final int index;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ShoppingItemDismissible({
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
        key: Key('dismiss_${item.id}'),
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
              builder: (context) => AddEditShoppingItemDialog(item: item),
            );
            return false;
          } else {
            return await showDialog<bool>(
              context: context,
              builder: (context) => DeleteShoppingItemDialog(
                itemId: item.id,
                itemName: item.name,
              ),
            );
          }
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            context.read<ShoppingListCubit>().deleteItem(item.id);
          }
        },
        child: ShoppingItemCard(
          item: item,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }
}
