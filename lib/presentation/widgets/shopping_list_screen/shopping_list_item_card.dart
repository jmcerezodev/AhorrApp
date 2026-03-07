import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_favorite_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/quick_price_dialog.dart';
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
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 75),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: item.isBought 
                  ? Colors.green.withValues(alpha: 0.3)
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // 1. ESTADO (CHECK)
                  _buildStatusIcon(),
                  
                  const SizedBox(width: 12),

                  // 2. INFO DEL PRODUCTO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface,
                            decoration: item.isBought ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.withValues(alpha: 0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. ZONA DE ACCIÓN PROTEGIDA (No dispara el check de la tarjeta)
                  GestureDetector(
                    onTap: () {}, // CAPTURA EL TAP PARA QUE NO LLEGUE AL PADRE
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // PRECIO CON CANTIDAD DEBAJO
                        _buildPriceSectionWithQuantity(context),
                        
                        const SizedBox(width: 10),

                        _buildFavoriteIcon(context, isAlreadyFavorite, favoriteId),
                        
                        const SizedBox(width: 10),

                        if (!item.isBought)
                          _buildVerticalStepperMinimal(context)
                        else
                          const SizedBox(width: 24),
                      ],
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

  Widget _buildStatusIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: (item.isBought ? Colors.green : Colors.orange).withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isBought ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
        color: item.isBought ? Colors.green : Colors.orange.withValues(alpha: 0.4),
        size: 18,
      ),
    );
  }

  Widget _buildVerticalStepperMinimal(BuildContext context) {
    return Container(
      width: 24,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButtonMinimal(
            icon: Icons.add_rounded,
            onTap: () => context.read<ShoppingListCubit>().updateItem(item.copyWith(quantity: item.quantity + 1)),
          ),
          _stepperButtonMinimal(
            icon: Icons.remove_rounded,
            onTap: item.quantity > 1 
              ? () => context.read<ShoppingListCubit>().updateItem(item.copyWith(quantity: item.quantity - 1))
              : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperButtonMinimal({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24,
        padding: const EdgeInsets.symmetric(vertical: 6), 
        color: Colors.transparent, 
        child: Icon(
          icon, 
          size: 16, 
          color: onTap != null ? Colors.orange : Colors.grey.withValues(alpha: 0.2)
        ),
      ),
    );
  }

  Widget _buildPriceSectionWithQuantity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.amount > 0) ...[
          Text(
            '${humanizeNumbers.number(item.amount * item.quantity)}€',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.2) : colorScheme.onSurface,
            ),
          ),
          if (item.quantity > 1)
            Text(
              '${humanizeNumbers.number(item.amount)}€/ud',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.orange.withValues(alpha: item.isBought ? 0.2 : 0.5),
              ),
            ),
        ] else
          GestureDetector(
            onTap: () => _showQuickPrice(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              child: Text(
                'PRECIO',
                style: TextStyle(color: Colors.orange.withValues(alpha: 0.5), fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        
        // Badge de cantidad DEBAJO del precio
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: item.isBought ? 0.4 : 1.0),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'x${item.quantity}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickPrice(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickPriceDialog(item: item),
    );
  }

  Widget _buildFavoriteIcon(BuildContext context, bool isAlreadyFavorite, String? favoriteId) {
    return GestureDetector(
      onTap: () {
        if (isAlreadyFavorite && favoriteId != null) {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<ShoppingTemplatesCubit>(),
              child: DeleteFavoriteDialog(templateId: favoriteId, productName: item.name),
            ),
          );
        } else {
          context.read<ShoppingTemplatesCubit>().saveTemplate(
            item.name, 
            [ShoppingTemplateItem(name: item.name, amount: item.amount, category: item.category)]
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0), 
        color: Colors.transparent,
        child: Icon(
          isAlreadyFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 22,
          color: Colors.orange.withValues(alpha: isAlreadyFavorite ? 1.0 : 0.4),
        ),
      ),
    );
  }
}
