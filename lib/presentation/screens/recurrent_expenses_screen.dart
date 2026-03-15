import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';
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
    Responsive.init(context);
    
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
      builder: (context, state) {
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- CABECERA ESTÁTICA ---
              // 1. APPBAR
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                from: 50.h,
                child: const RecurrentAppBar(),
              ),

              // 2. TARJETA DE RESUMEN
              RecurrentSummaryWidget(
                isIncomeTab: _currentTabIndex == 1,
              ),

              // 3. PESTAÑAS
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                from: 50.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w, 
                    vertical: isSmallScreen ? 5.h : 10.h
                  ),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(25.w),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.w),
                        color: Colors.orange,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
                      tabs: const [
                        Tab(text: 'GASTOS'),
                        Tab(text: 'INGRESOS'),
                      ],
                    ),
                  ),
                ),
              ),

              // --- CUERPO SCROLLABLE ---
              Expanded(
                child: state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 50.h,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
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
