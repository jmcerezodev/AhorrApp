import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/background/pending_ocr_worker.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/add_edit_ticket_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/delete_ticket_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/ticket_item_card.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workmanager/workmanager.dart';

class TicketsHistoryWidget extends StatefulWidget {
  const TicketsHistoryWidget({super.key});

  @override
  State<TicketsHistoryWidget> createState() => _TicketsHistoryWidgetState();
}

class _TicketsHistoryWidgetState extends State<TicketsHistoryWidget> {
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
    final humanizeNumbers = HumanizeNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        final items = state.filteredItems;

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.orange,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 100.h),
                EmptyListWidget(
                  text: state.searchQuery.isEmpty 
                    ? 'Aún no tienes tickets registrados.\n¡Escanea o añade uno manualmente!' 
                    : 'No se encontraron tickets\nque coincidan con tu búsqueda.',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: Colors.orange,
          child: ReorderableListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) => context.read<TicketsCubit>().reorderItems(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final item = items[index];
              final card = Padding(
                key: ValueKey(item.id),
                padding: EdgeInsets.only(bottom: 8.h),
                child: Dismissible(
                  key: Key('dismiss_${item.id}'),
                  direction: DismissDirection.horizontal,
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

              if (_hasAnimated) return card;

              return FadeInUp(
                key: ValueKey('anim_${item.id}'),
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: index * 20),
                from: 30.h,
                child: card,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleRefresh() async {
    // 1. Lanzamos el worker manual
    await Workmanager().registerOneOffTask(
      "pull_refresh_${DateTime.now().millisecondsSinceEpoch}", 
      kPendingOcrTaskName, // processPendingOcrTicketsV2
    );

    // 2. Pequeño delay para dar tiempo a que el worker inicie y OpenAI trabaje
    // El RefreshIndicator se detendrá cuando termine este delay
    await Future.delayed(const Duration(seconds: 4));

    // 3. Refrescamos la UI silenciosamente
    if (mounted) {
      await context.read<TicketsCubit>().refreshListSilently();
    }
  }
}
