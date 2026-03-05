import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_app_bar.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_history_widget.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_summary_widget.dart';
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
    // Cargamos los items al entrar
    context.read<ShoppingListCubit>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. APPBAR (Añadir producto)
            ShoppingAppBar(),

            // 2. RESUMEN (Total y Progreso)
            ShoppingSummaryWidget(),

            // 3. LISTADO (Lista reordenable y acciones)
            Expanded(
              child: ShoppingListHistoryWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
