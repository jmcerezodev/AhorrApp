import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_cubit.dart';
import 'package:ahorrapp/presentation/widgets/shopping_screen/shopping_app_bar.dart';
import 'package:ahorrapp/presentation/widgets/shopping_screen/shopping_history_widget.dart';
import 'package:ahorrapp/presentation/widgets/shopping_screen/shopping_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos los items al entrar
    context.read<ShoppingCubit>().loadItems();
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
              child: ShoppingHistoryWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
