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

class _RecurrentExpensesScreenState extends State<RecurrentExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
    // Cargamos tanto los gastos fijos como las deudas/préstamos para asegurar la sincronización de títulos y chips
    context.read<RecurrentExpensesCubit>().loadExpenses();
    context.read<DebtsLoansCubit>().loadDebtsLoans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              // 1. APPBAR - Desde arriba
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                from: 100,
                child: const RecurrentAppBar(),
              ),

              // 2. TARJETA DE RESUMEN
              RecurrentSummaryWidget(
                isIncomeTab: _currentTabIndex == 1,
              ),

              // 3. PESTAÑAS - Desde la IZQUIERDA
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                from: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.orange,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: 'GASTOS'),
                        Tab(text: 'INGRESOS'),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. LISTADOS - Desde abajo
              Expanded(
                child: state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 100,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          RecurrentHistoryWidget(isIncomeTab: false),
                          RecurrentHistoryWidget(isIncomeTab: true),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
