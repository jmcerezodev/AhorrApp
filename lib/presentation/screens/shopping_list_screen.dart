import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_app_bar.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_history_widget.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_summary_widget.dart';
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
    context.read<ShoppingListCubit>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. APPBAR
          const ShoppingListAppBar(),

          // 2. RESUMEN
          const ShoppingSummaryWidget(),

          // 3. BOTONES DE ACCIÓN (2 COLUMNAS)
          BlocBuilder<ShoppingListCubit, ShoppingState>(
            builder: (context, state) {
              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // COLUMNA 1: MIS FAVORITOS
                      Expanded(
                        child: _ActionButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: context.read<ShoppingTemplatesCubit>()),
                                  BlocProvider.value(value: context.read<ShoppingListCubit>()),
                                ],
                                child: const ShoppingTemplatesDialog(),
                              ),
                            );
                          },
                          icon: Icons.stars_rounded,
                          label: 'MIS FAVORITOS',
                          color: Colors.orange,
                        ),
                      ),
                      
                      const SizedBox(width: 10),

                      // COLUMNA 2: AÑADIR A GASTOS (Se desactiva si totalBought == 0)
                      Expanded(
                        child: _ActionButton(
                          onPressed: state.totalBought > 0 
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ShoppingListCubit>(),
                                    child: const TransferToExpensesDialog(),
                                  ),
                                );
                              }
                            : null, // Desactivado
                          icon: Icons.receipt_long_rounded,
                          label: 'AÑADIR A GASTOS', // TEXTO AÚN MÁS RESUMIDO
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. LISTADO
          const Expanded(
            child: ShoppingListHistoryWidget(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: FittedBox(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
          foregroundColor: isEnabled ? color : Colors.grey.withValues(alpha: 0.3),
          elevation: 0,
          side: BorderSide(
            color: isEnabled ? color : Colors.grey.withValues(alpha: 0.1), 
            width: 1.5
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
