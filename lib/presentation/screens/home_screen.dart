import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
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
  bool _isSyncDialogOpen = false; // Bandera local para control de seguridad

  @override
  void initState() {
    super.initState();
    authAppwrite.checkUserAuthentication(context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final dateState = context.read<DateCubit>().state;
        context.read<HistoryCubit>().loadHistoryByDate(dateState.month, dateState.year);
        context.read<SavingsCubit>().loadSavings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String yearNow = Date().year();
    final String userName = Preferences.name;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCalendarOpen = context.watch<DateCubit>().state.isOpen;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, 
      drawer: const SideMenuWidget(),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<DateCubit, DateCubitState>(
              listenWhen: (previous, current) => previous.month != current.month || previous.year != current.year,
              listener: (context, state) {
                context.read<HistoryCubit>().loadHistoryByDate(state.month, state.year);
              },
            ),
            // GESTIÓN CORREGIDA DEL DIÁLOGO DE SINCRONIZACIÓN
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
                  // Cerramos solo si el diálogo está abierto
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
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: Icon(Icons.notes_rounded, color: colorScheme.onSurface, size: 28),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Hola, $userName',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            Text(
                              'Bienvenido de nuevo',
                              style: TextStyle(fontSize: 12, color: colorScheme.primary.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const InfoGlogalWidget(),
                  const SizedBox(height: 5),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: DateCustomWidget()),
                        SizedBox(width: 12),
                        Expanded(flex: 2, child: MonthlyBalanceWidget()),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  const ExpensesIncomesCustomWidget(),
                  const SizedBox(height: 25),
                  
                  const Expanded(
                    child: HistoryCustomWidget(),
                  ),
                  
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'JMCerezoDev - $yearNow ®',
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),

              if (isCalendarOpen)
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  child: const CalendarPanelWidget(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
