import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/sync_progress_dialog.dart';
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
        context.read<HistoryCubit>().loadHistoryByDate(dateState.month, dateState.year);
        context.read<SavingsCubit>().loadSavings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              context.read<HistoryCubit>().loadHistoryByDate(state.month, state.year);
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
              }
            },
          ),
        ],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5), // Reducido de 15 a 10
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
                            'Hola, $userName',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                          ),
                          Text(
                            '$greeting de nuevo',
                            style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      
                const InfoGlogalWidget(), // Tarjeta de balance
      
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2), // Reducido de 5 a 2
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: DateCustomWidget()),
                      SizedBox(width: 12),
                      Expanded(flex: 2, child: MonthlyBalanceWidget()),
                    ],
                  ),
                ),
      
                const SizedBox(height: 5), // Reducido de 10 a 5
                const ExpensesIncomesCustomWidget(),
                const SizedBox(height: 10), // Reducido de 20 a 10
                
                const Expanded(
                  child: HistoryCustomWidget(),
                ),
                
                const SizedBox(height: 5), // Reducido de 10 a 5
              ],
            ),
      
            if (isCalendarOpen)
              Positioned(
                top: 200, // Ajustado de 220 a 200 por la compactación
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
