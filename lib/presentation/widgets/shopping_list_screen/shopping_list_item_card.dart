import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_favorite_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/quick_price_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingTemplatesCubit, ShoppingTemplatesState>(
      builder: (context, templatesState) {
        final bool isAlreadyFavorite = templatesState.isFavorite(item.name);
        final String? favoriteId = templatesState.getFavoriteId(item.name);

        return GestureDetector(
          onTap: () => context.read<ShoppingListCubit>().toggleItem(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 75),
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
                  // 1. ICONO DE ESTADO (CHECK)
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

                  // 2. INFORMACIÓN DEL PRODUCTO
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
                                    'En la cesta',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900, 
                                      color: Colors.green
                                    )
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4), // ESPACIO AUMENTADO
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

                  // 3. SECCIÓN DE PRECIO
                  if (item.amount > 0)
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${humanizeNumbers.number(item.amount)}€',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface,
                        ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'PRECIO',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(width: 12),

                  // 4. BOTÓN DE FAVORITO (TOGGLE)
                  GestureDetector(
                    onTap: () {
                      if (isAlreadyFavorite && favoriteId != null) {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ShoppingTemplatesCubit>(),
                            child: DeleteFavoriteDialog(
                              templateId: favoriteId,
                              productName: item.name,
                            ),
                          ),
                        );
                      } else {
                        context.read<ShoppingTemplatesCubit>().saveTemplate(
                          item.name, 
                          [ShoppingTemplateItem(name: item.name, amount: item.amount, category: item.category)]
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${item.name}" guardado en favoritos'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          )
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAlreadyFavorite 
                            ? Colors.orange.withValues(alpha: 0.2) 
                            : Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isAlreadyFavorite 
                              ? Colors.orange.withValues(alpha: 0.4) 
                              : Colors.orange.withValues(alpha: 0.1)
                        ),
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        size: 18, 
                        color: isAlreadyFavorite ? Colors.orange : Colors.orange.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
