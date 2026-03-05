import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/transfer_to_expenses_dialog.dart';
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

          // 3. BOTÓN DE TRANSFERENCIA (DINÁMICO)
          BlocBuilder<ShoppingListCubit, ShoppingState>(
            builder: (context, state) {
              if (state.totalBought == 0) return const SizedBox(height: 10);

              return FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ShoppingListCubit>(),
                            child: const TransferToExpensesDialog(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 20),
                      label: const Text(
                        'AÑADIR COMPRA A LA LISTA DE GASTOS',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        foregroundColor: Colors.orange,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.orange, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
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
