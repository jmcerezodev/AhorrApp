import 'package:ahorrapp/core/config/responsive_utils.dart';
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
  bool _hasAnimated = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _hasAnimated = true);
      });
    });
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

    return BlocBuilder<DebtsLoansCubit, DebtsLoansState>(
      builder: (context, state) {
        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. APPBAR (FIJO)
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                from: 50.h,
                child: _buildAppBar(context, colorScheme),
              ),

              // 2. RESUMEN (FIJO)
              DebtsSummaryWidget(
                totalAmount: _currentTabIndex == 0 ? state.totalDebts : state.totalLoans,
                isDebtView: _currentTabIndex == 0,
              ),

              // 3. PESTAÑAS (FIJO)
              FadeInRight(
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
                        Tab(text: 'DEUDAS'),
                        Tab(text: 'PRÉSTAMOS'),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. LISTADO (SCROLLABLE INDEPENDIENTE)
              Expanded(
                child: state.isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 50.h,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
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
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface, size: 30.w),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'CUENTAS PENDIENTES',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Lo que debes y lo que te deben.',
                style: TextStyle(
                  fontSize: 11.sp,
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
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 100.h),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final card = DebtLoanCard(
          item: item, 
          isDark: isDark, 
          colorScheme: colorScheme,
        );

        if (_hasAnimated) return card;

        return FadeInUp(
          key: ValueKey('debt_anim_${item.id}'),
          duration: const Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 30),
          from: 30.h,
          child: card,
        );
      },
    );
  }
}
