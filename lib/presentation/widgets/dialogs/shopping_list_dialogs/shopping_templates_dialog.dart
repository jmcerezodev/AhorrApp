import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ShoppingTemplatesDialog extends StatefulWidget {
  const ShoppingTemplatesDialog({super.key});

  @override
  State<ShoppingTemplatesDialog> createState() => _ShoppingTemplatesDialogState();
}

class _ShoppingTemplatesDialogState extends State<ShoppingTemplatesDialog> {
  @override
  void initState() {
    super.initState();
    context.read<ShoppingTemplatesCubit>().loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: BlocBuilder<ShoppingTemplatesCubit, ShoppingTemplatesState>(
        builder: (context, state) {
          final bool isEmpty = state.templates.isEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppDialogs.dialogRowHeader(
                      icon: Icons.stars_rounded, 
                      title: 'Mis Favoritos', 
                      color: Colors.orange, 
                      colorScheme: colorScheme
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<ShoppingTemplatesCubit>(),
                          child: const AddEditFavoriteDialog(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.orange, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              if (state.status == ShoppingTemplatesStatus.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                )
              else if (isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Icon(Icons.stars_rounded, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                      const SizedBox(height: 15),
                      AppDialogs.dialogMessage(
                        'Guarda productos frecuentes pulsando la estrella para añadirlos rápido.',
                        colorScheme,
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _TemplateItem(template: state.templates[index]);
                    },
                  ),
                ),

              const SizedBox(height: 25),
              
              SizedBox(
                width: double.infinity,
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CERRAR', 
                  onPressed: () => context.pop(), 
                  colorScheme: colorScheme
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TemplateItem extends StatelessWidget {
  final ShoppingTemplate template;
  const _TemplateItem({required this.template});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    final product = template.items.first;
    final bool hasPrice = product.amount > 0;

    return Dismissible(
      key: Key('fav_${template.id}'),
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
            builder: (_) => BlocProvider.value(
              value: context.read<ShoppingTemplatesCubit>(),
              child: AddEditFavoriteDialog(favorite: template),
            ),
          );
          return false;
        } else {
          return await showDialog<bool>(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<ShoppingTemplatesCubit>(),
              child: DeleteFavoriteDialog(
                templateId: template.id,
                productName: product.name,
              ),
            ),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 70),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.category.toUpperCase(),
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

              if (hasPrice)
                Text(
                  '${humanizeNumbers.number(product.amount)}€',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<ShoppingTemplatesCubit>(),
                        child: AddEditFavoriteDialog(
                          favorite: template,
                          focusPrice: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      'SIN PRECIO',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(width: 12),

              GestureDetector(
                onTap: () {
                  context.read<ShoppingListCubit>().addItemsFromTemplate(template.items);
                  AppDialogs.showCustomDialog(
                    context: context,
                    builder: SuccessfulDialogNoGo(
                      title: '¡A la Cesta!',
                      sucessfulName: '¡${product.name} añadido correctamente!',
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded, 
                    size: 18, 
                    color: Colors.orange
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
