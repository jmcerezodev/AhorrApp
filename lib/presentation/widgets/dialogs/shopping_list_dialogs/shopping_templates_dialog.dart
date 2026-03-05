import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_favorite_dialog.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4), 
            width: 1.5
          ),
        ),
        child: BlocBuilder<ShoppingTemplatesCubit, ShoppingTemplatesState>(
          builder: (context, state) {
            final bool isEmpty = state.templates.isEmpty;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.orange, size: 24),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'MIS FAVORITOS',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.stars_rounded, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                        const SizedBox(height: 10),
                        const Text(
                          'Guarda productos de tu lista\npulsando el icono de la estrella.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
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
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'CERRAR', 
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4), 
                        fontWeight: FontWeight.w900, 
                        fontSize: 12,
                        letterSpacing: 1
                      )
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Row(
                  children: [
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.orange.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${humanizeNumbers.number(product.amount)}€',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<ShoppingListCubit>().addItemsFromTemplate(template.items);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${product.name}" añadido'),
                  backgroundColor: Colors.green,
                  duration: const Duration(milliseconds: 800),
                )
              );
            },
            icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.orange),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: context.read<ShoppingTemplatesCubit>(),
                  child: DeleteFavoriteDialog(
                    templateId: template.id,
                    productName: product.name,
                  ),
                ),
              );
            },
            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
