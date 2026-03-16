import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/add_edit_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_item_card.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingListHistoryWidget extends StatefulWidget {
  const ShoppingListHistoryWidget({super.key});

  @override
  State<ShoppingListHistoryWidget> createState() => _ShoppingListHistoryWidgetState();
}

class _ShoppingListHistoryWidgetState extends State<ShoppingListHistoryWidget> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _hasAnimated = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
          child: Text(
            'LISTA ACTUAL',
            style: TextStyle(
              fontSize: 11.sp,
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
                return const EmptyListWidget(
                  text: 'No tienes productos pendientes.\n¡Añade lo que necesites para tu próxima compra!',
                );
              }

              return ReorderableListView.builder(
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 100.h),
                physics: const BouncingScrollPhysics(),
                itemCount: state.items.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<ShoppingListCubit>().reorderItems(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final listItem = _ShoppingItemDismissible(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    humanizeNumbers: humanizeNumbers,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );

                  if (_hasAnimated) return listItem;

                  return FadeInLeft(
                    key: ValueKey('anim_${item.id}'),
                    duration: const Duration(milliseconds: 400),
                    delay: Duration(milliseconds: index * 20),
                    from: 30.w,
                    child: listItem,
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
      padding: EdgeInsets.only(bottom: 8.h),
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
