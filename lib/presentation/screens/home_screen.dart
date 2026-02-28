import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
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

  @override
  void initState() {
    super.initState();
    authAppwrite.checkUserAuthentication(context);
    
    // ASEGURAMOS CARGA DE DATOS AL ENTRAR
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryCubit>().loadHistory();
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, 
      drawer: const SideMenuWidget(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
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
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
