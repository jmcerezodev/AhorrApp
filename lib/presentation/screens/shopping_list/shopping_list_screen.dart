import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/add_edit_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_shopping_item_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/quick_price_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingCubit>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // APPBAR COMPACTA
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 20, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LISTA DE LA COMPRA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Gestiona tus productos pendientes',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AddEditShoppingItemDialog(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 1.5)
                      ),
                      child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.orange, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // TARJETA DE RESUMEN
            BlocBuilder<ShoppingCubit, ShoppingState>(
              builder: (context, state) {
                if (state.items.isEmpty) return const SizedBox.shrink();

                return FadeInDown(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        gradient: isDark 
                          ? const LinearGradient(
                              colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3), 
                          width: 1.5
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL ESTIMADO',
                                style: TextStyle(
                                  color: Colors.orange.shade400,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${humanizeNumbers.number(state.totalPrice)}€',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PROGRESO',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${state.totalBought}/${state.items.length}',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
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

            const SizedBox(height: 10),

            Expanded(
              child: BlocBuilder<ShoppingCubit, ShoppingState>(
                builder: (context, state) {
                  if (state.status == ShoppingStatus.loading && state.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.items.isEmpty) {
                    return _EmptyShoppingState(colorScheme: colorScheme);
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.items.length,
                    onReorder: (oldIndex, newIndex) {
                      context.read<ShoppingCubit>().reorderItems(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return FadeInUp(
                        key: ValueKey(item.id),
                        delay: Duration(milliseconds: 50 * index),
                        child: _ShoppingItemDismissible(
                          item: item,
                          humanizeNumbers: humanizeNumbers,
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemDismissible extends StatelessWidget {
  final ShoppingItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ShoppingItemDismissible({
    required this.item,
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
            context.read<ShoppingCubit>().deleteItem(item.id);
          }
        },
        child: _ShoppingCard(
          item: item,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  final ShoppingItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ShoppingCard({
    required this.item,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ShoppingCubit>().toggleItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isBought 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item.isBought ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isBought ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: item.isBought ? Colors.green : Colors.orange.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.4) : colorScheme.onSurface,
                              decoration: item.isBought ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (item.isBought) ...[
                          const SizedBox(width: 8),
                          FadeInLeft(
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'EN EL CARRITO', 
                                style: TextStyle(
                                  fontSize: 7, 
                                  fontWeight: FontWeight.w900, 
                                  color: Colors.green
                                )
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      item.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // SECCIÓN DE PRECIO O BOTÓN DE AÑADIR RÁPIDO
              if (item.amount > 0)
                Text(
                  '${humanizeNumbers.number(item.amount)}€',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => QuickPriceDialog(item: item),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.euro_rounded, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'PRECIO',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShoppingState extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptyShoppingState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset('assets/Logo.png', height: 60, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'LISTA VACÍA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text(
              'No tienes productos pendientes. ¡Añade lo que necesites para tu próxima compra!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
