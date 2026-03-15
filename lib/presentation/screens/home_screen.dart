import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authAppwrite = AuthAppwrite();
  bool _isSyncDialogOpen = false; 

  @override
  void initState() {
    super.initState();
    authAppwrite.checkUserAuthentication(context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UpdateNameCubit>().resetCubit();
        
        final dateState = context.read<DateCubit>().state;
        final savingsCubit = context.read<SavingsCubit>();
        
        context.read<HistoryCubit>().loadHistoryByDate(
          dateState.month, 
          dateState.year, 
          savingsCubit: savingsCubit
        );
        
        savingsCubit.loadSavings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final String userName = context.watch<UpdateNameCubit>().state.name;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCalendarOpen = context.watch<DateCubit>().state.isOpen;

    String greeting = 'Bienvenido';
    if (userName.isNotEmpty) {
      final String firstWord = userName.trim().split(' ').first.toLowerCase();
      
      const femaleExceptions = {
        'raquel', 'isabel', 'belen', 'pilar', 'carmen', 'lourdes', 
        'concepcion', 'concha', 'mercedes', 'dolores', 'rosario', 
        'ester', 'esther', 'miriam', 'iris', 'ruth', 'abril', 'lucia'
      };

      if (firstWord.endsWith('a') || femaleExceptions.contains(firstWord)) {
        const maleNamesWithA = {'luca', 'borja', 'bautista', 'josua'};
        if (!maleNamesWithA.contains(firstWord)) {
          greeting = 'Bienvenida';
        }
      }
    }

    return SafeArea(
      bottom: false,
      child: MultiBlocListener(
        listeners: [
          BlocListener<DateCubit, DateCubitState>(
            listenWhen: (previous, current) => previous.month != current.month || previous.year != current.year,
            listener: (context, state) {
              context.read<HistoryCubit>().loadHistoryByDate(
                state.month, 
                state.year, 
                savingsCubit: context.read<SavingsCubit>()
              );
            },
          ),
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
                context.read<SavingsCubit>().loadSavings();
              }
            },
          ),
        ],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header: Saludo y Menú (FIJO)
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    from: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface, size: 30.sp),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Hola, $userName',
                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                            ),
                            Text(
                              '$greeting de nuevo',
                              style: TextStyle(fontSize: 12.sp, color: Colors.orange, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Info Global: Balance (FIJO)
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  from: 100,
                  child: const InfoGlogalWidget()
                ),

                // 3. Fecha y Balance Mensual (FIJO)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3, 
                        child: FadeInLeft(
                          delay: const Duration(milliseconds: 200),
                          from: 100,
                          child: const DateCustomWidget()
                        )
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2, 
                        child: FadeInRight(
                          delay: const Duration(milliseconds: 200),
                          from: 100,
                          child: const MonthlyBalanceWidget()
                        )
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5.h),

                // 4. Botones Ingresos/Gastos (FIJO)
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  from: 100,
                  child: const ExpensesIncomesCustomWidget()
                ),

                SizedBox(height: 10.h),
                
                // 5. Historial (SCROLLABLE)
                const Expanded(
                  child: HistoryCustomWidget(isSliver: false),
                ),
                
                SizedBox(height: 5.h),
              ],
            ),
      
            if (isCalendarOpen)
              Positioned(
                top: 200.h,
                left: 0,
                right: 0,
                child: const CalendarPanelWidget(),
              ),
          ],
        ),
      ),
    );
  }
}
