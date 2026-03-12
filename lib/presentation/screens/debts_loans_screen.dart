import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/debts_loans_screen/debt_loan_card.dart';
import 'package:ahorrapp/presentation/widgets/debts_loans_screen/debts_summary_widget.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DebtsLoansScreen extends StatefulWidget {
  const DebtsLoansScreen({super.key});

  @override
  State<DebtsLoansScreen> createState() => _DebtsLoansScreenState();
}

class _DebtsLoansScreenState extends State<DebtsLoansScreen> with SingleTickerProviderStateMixin {
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

    return BlocBuilder<DebtsLoansCubit, DebtsLoansState>(
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              // 1. APPBAR - Desde arriba
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                from: 100,
                child: _buildAppBar(context, colorScheme),
              ),

              // 2. RESUMEN - Desde arriba
              DebtsSummaryWidget(
                totalAmount: _currentTabIndex == 0 ? state.totalDebts : state.totalLoans,
                isDebtView: _currentTabIndex == 0,
              ),

              // 3. PESTAÑAS - Desde la DERECHA (FadeInRight) para Deudas
              FadeInRight(
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
                        Tab(text: 'MIS DEUDAS'),
                        Tab(text: 'PRÉSTAMOS'),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. LISTADO - Desde abajo
              Expanded(
                child: state.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 100,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildList(state.debtsLoans.where((e) => e.type == DebtLoanType.debt).toList(), true),
                          _buildList(state.debtsLoans.where((e) => e.type == DebtLoanType.loan).toList(), false),
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

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface, size: 30),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'CUENTAS PENDIENTES',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const Text(
                'Lo que debes y lo que te deben.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<DebtLoan> items, bool isDebt) {
    if (items.isEmpty) {
      return EmptyListWidget(
        text: isDebt 
          ? 'No tienes deudas pendientes.\n¡Estás al día con tus pagos!' 
          : 'No has realizado préstamos.\nNo te debe dinero nadie.',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return DebtLoanCard(
          item: item, 
          isDark: isDark, 
          colorScheme: colorScheme,
        );
      },
    );
  }
}
