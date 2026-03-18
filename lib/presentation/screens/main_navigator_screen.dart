import 'dart:math';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/process_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/screens/home_screen.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/screens/shopping_list_screen.dart';
import 'package:ahorrapp/presentation/screens/tickets_screen.dart';
import 'package:ahorrapp/presentation/screens/debts_loans_screen.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _selectedIndex = 2; // El botón central (Inicio) es el índice 2
  bool _isSyncDialogOpen = false;

  final List<Widget> _screens = [
    const RecurrentExpensesScreen(key: ValueKey('recurrent')),
    const ShoppingListScreen(key: ValueKey('shopping')),
    const HomeScreen(key: ValueKey('home')),
    const TicketsScreen(key: ValueKey('tickets')),
    const DebtsLoansScreen(key: ValueKey('debts')),
  ];

  @override
  void initState() {
    super.initState();
    _processRecurrentExpenses();
  }

  Future<void> _processRecurrentExpenses() async {
    final String userId = Preferences.uId;
    if (userId.isEmpty) return;

    await getIt<ProcessRecurrentExpensesUseCase>().call(userId);

    if (mounted) {
      final dateState = context.read<DateCubit>().state;
      // Refrescar historial con los nuevos movimientos generados
      context.read<HistoryCubit>().loadHistoryByDate(dateState.month, dateState.year);
      // Refrescar gastos fijos y deudas: el procesador puede haber actualizado
      // lastApplied y paidAmount directamente en Isar sin pasar por los cubits.
      context.read<RecurrentExpensesCubit>().loadExpenses();
      context.read<DebtsLoansCubit>().loadDebtsLoans();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // iPhone 7 tiene 375 de ancho. S23 Ultra tiene ~412.
    final bool isIphone7 = screenWidth <= 375;

    return MultiBlocListener(
      listeners: [
        BlocListener<HistoryCubit, HistoryCubitState>(
          listenWhen: (prev, curr) => prev.isSyncing != curr.isSyncing,
          listener: (context, state) {
            if (state.isSyncing && !_isSyncDialogOpen) {
              _isSyncDialogOpen = true;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => BlocProvider.value(
                  value: context.read<HistoryCubit>(),
                  child: BlocBuilder<HistoryCubit, HistoryCubitState>(
                    builder: (context, state) => SyncProgressDialog(progress: state.syncProgress),
                  ),
                ),
              ).then((_) => _isSyncDialogOpen = false);
            } else if (!state.isSyncing && _isSyncDialogOpen) {
              Navigator.of(context, rootNavigator: true).pop();
              _isSyncDialogOpen = false;
              // Recargamos datos de los cubits principales tras la sincronización
              context.read<SavingsCubit>().loadSavings();
              context.read<TicketsCubit>().loadItems();
              context.read<DebtsLoansCubit>().loadDebtsLoans();
            }
          },
        ),
      ],
      child: Scaffold(
        drawer: const SideMenuWidget(),
        resizeToAvoidBottomInset: false, 
        body: Column(
          children: [
            StreamBuilder<NetworkStatus>(
              stream: getIt<ConnectivityService>().status,
              initialData: getIt<ConnectivityService>().currentStatus,
              builder: (context, snapshot) {
                if (snapshot.data == NetworkStatus.offline) {
                  return SafeArea(
                    bottom: false,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w),
                      color: Colors.orange.shade800.withValues(alpha: 0.9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Modo Local: Los datos se sincronizarán al volver la conexión.',
                              style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                    child: child,
                  );
                },
                child: _screens[_selectedIndex],
              ),
            ),
          ],
        ),
        bottomNavigationBar: DefaultTextStyle(
          style: TextStyle(fontSize: isIphone7 ? 8 : 10, fontWeight: FontWeight.bold),
          child: ConvexAppBar(
            style: TabStyle.fixedCircle,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            color: Colors.grey.shade400,
            activeColor: Colors.orange,
            initialActiveIndex: _selectedIndex,
            height: isIphone7 ? 75 : 65.h, 
            top: isIphone7 ? -15 : -22.h,   
            curveSize: isIphone7 ? 70 : 85.w,
            items: [
              TabItem(icon: Icons.repeat_rounded, title: isIphone7 ? 'Fijo' : 'Fijos'),
              TabItem(icon: Icons.shopping_basket_rounded, title: isIphone7 ? 'Compra' : 'Compra'),
              TabItem(icon: Icons.home_rounded, title: 'Inicio'),
              TabItem(icon: Icons.qr_code_scanner_rounded, title: 'Tickets'),
              TabItem(icon: Icons.handshake_rounded, title: 'Deudas'),
            ],
            onTap: (int i) => setState(() => _selectedIndex = i),
          ),
        ),
      ),
    );
  }
}
