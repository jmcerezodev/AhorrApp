import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/add_edit_shopping_item_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingSummaryWidget extends StatelessWidget {
  const ShoppingSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ShoppingListCubit, ShoppingState>(
      builder: (context, state) {
        return FadeInDown(
          duration: const Duration(milliseconds: 400),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // COLUMNA 1: INFO (Total + En la cesta)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL EN LA CESTA',
                            style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${humanizeNumbers.number(state.totalBoughtPrice)}€',
                              style: TextStyle(
                                color: isDark ? Colors.white : colorScheme.onSurface,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Progreso:',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${state.totalBought}/${state.items.length}',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    // COLUMNA 2: BURBUJA DE ACCIÓN (Botón de añadir)
                    const _AddProductBubble(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddProductBubble extends StatelessWidget {
  const _AddProductBubble();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AddEditShoppingItemDialog(),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.orange,
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'AÑADIR',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.orange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
