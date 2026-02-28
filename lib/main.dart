import 'package:ahorrapp/config/routes/app_router.dart';
import 'package:ahorrapp/config/theme/app_theme.dart';
import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Importado para salir de la app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final authService = AuthAppwrite();
  final biometricService = BiometricService();
  
  String initialRoute = '/login';
  bool isAuthRequired = Preferences.uId.isNotEmpty;

  if (isAuthRequired) {
    if (Preferences.isBiometricActive) {
      final bool authenticated = await biometricService.authenticate();
      if (authenticated) {
        initialRoute = await authService.getInitialRoute();
      } else {
        // SEGURIDAD EXTREMA: Cerramos la app si no se identifica al abrir
        exit(0); 
      }
    } else {
      initialRoute = await authService.getInitialRoute();
    }
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: MainAppWrapper(initialRoute: initialRoute),
    )
  );
}

class MainAppWrapper extends StatefulWidget {
  final String initialRoute;
  const MainAppWrapper({super.key, required this.initialRoute});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> with WidgetsBindingObserver {
  late GoRouter router;
  final totalMoneyCubit = TotalMoneyCubit();
  bool _isAuthenticating = false;
  bool _wasPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    router = getAppRouter(widget.initialRoute);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasPaused = true;
    }

    if (state == AppLifecycleState.resumed && _wasPaused) {
      _wasPaused = false;
      _checkBiometricsOnResume();
    }
  }

  Future<void> _checkBiometricsOnResume() async {
    if (Preferences.uId.isEmpty || !Preferences.isBiometricActive || _isAuthenticating) return;

    _isAuthenticating = true;
    
    final biometricService = BiometricService();
    final authenticated = await biometricService.authenticate();
    
    if (!authenticated) {
      // SEGURIDAD EXTREMA: Cerramos la app si falla al volver de segundo plano
      exit(0); 
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => NewUserCubit()),
        BlocProvider(create: (_) => ResetPasswordCubit()),
        BlocProvider(create: (_) => UpdatePasswordCubit()),
        BlocProvider(create: (_) => UpdateNameCubit()),
        BlocProvider(create: (_) => DeleteAcountCubit()),
        BlocProvider(create: (_) => SavingsCubit()),
        BlocProvider.value(value: totalMoneyCubit),
        BlocProvider(create: (_) => DateCubit()),
        BlocProvider(create: (_) => IncomesCubit()),
        BlocProvider(create: (_) => ExpensesCubit()),
        BlocProvider(create: (_) => HistoryCubit(totalMoneyCubit: totalMoneyCubit)),
      ],
      child: MaterialApp.router(
        title: 'AhorrApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(isDarkMode: false),
        darkTheme: AppTheme().getTheme(isDarkMode: true),
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
