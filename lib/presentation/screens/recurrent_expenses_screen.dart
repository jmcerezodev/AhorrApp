import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_app_bar.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_history_widget.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentExpensesScreen extends StatefulWidget {
  const RecurrentExpensesScreen({super.key});

  @override
  State<RecurrentExpensesScreen> createState() => _RecurrentExpensesScreenState();
}

class _RecurrentExpensesScreenState extends State<RecurrentExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecurrentExpensesCubit>().loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. APPBAR COMPACTA
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: const RecurrentAppBar()
          ),

          // 2. TARJETA DE RESUMEN
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: const RecurrentSummaryWidget()
          ),

          const SizedBox(height: 10),

          // 3. LISTADO Y FILTROS
          Expanded(
            child: FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const RecurrentHistoryWidget()
            ),
          ),
        ],
      ),
    );
  }
}
