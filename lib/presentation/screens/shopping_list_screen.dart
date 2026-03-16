import 'package:ahorrapp/core/config/responsive_utils.dart';
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
    Responsive.init(context);
    
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. APPBAR (FIJO)
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            from: 50.h,
            child: const ShoppingListAppBar()
          ),

          // 2. RESUMEN (FIJO)
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            from: 50.h,
            child: const ShoppingSummaryWidget()
          ),

          // 3. BOTONES DE ACCIÓN (FIJO)
          BlocBuilder<ShoppingListCubit, ShoppingState>(
            builder: (context, state) {
              return FadeInUp(
                delay: const Duration(milliseconds: 200),
                from: 50.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
                      
                      SizedBox(width: 10.w),

                      // COLUMNA 2: AÑADIR A GASTOS
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
                            : null,
                          icon: Icons.receipt_long_rounded,
                          label: 'AÑADIR A GASTOS',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. LISTADO (SCROLLABLE INDEPENDIENTE)
          Expanded(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              from: 50.h,
              child: const ShoppingListHistoryWidget()
            ),
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
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.w),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, letterSpacing: 0.5),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
          foregroundColor: isEnabled ? color : Colors.grey.withValues(alpha: 0.3),
          elevation: 0,
          side: BorderSide(
            color: isEnabled ? color : Colors.grey.withValues(alpha: 0.1), 
            width: 1.5.w
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
          ),
        ),
      ),
    );
  }
}
