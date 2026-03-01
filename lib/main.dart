import 'package:ahorrapp/config/routes/app_router.dart';
import 'package:ahorrapp/config/theme/app_theme.dart';
import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. INICIALIZAMOS PREFERENCIAS Y EL SERVICE LOCATOR (Clean Architecture)
    await Preferences.init();
    await setupServiceLocator();
    
    // 2. INICIALIZAMOS EL SERVICIO DE SINCRONIZACIÓN OFFLINE
    getIt<SyncService>().init();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final authService = getIt<AuthAppwrite>();
    final biometricService = getIt<BiometricService>();
    
    String initialRoute = '/login';
    bool isAuthRequired = Preferences.uId.isNotEmpty;

    if (isAuthRequired) {
      if (Preferences.isBiometricActive) {
        final bool authenticated = await biometricService.authenticate();
        if (authenticated) {
          initialRoute = await authService.getInitialRoute();
        } else {
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
  } catch (e) {
    debugPrint("❌ Error fatal durante la inicialización: $e");
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Error de Inicialización',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'La aplicación no pudo iniciarse correctamente.\n\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MainAppWrapper extends StatefulWidget {
  final String initialRoute;
  const MainAppWrapper({super.key, required this.initialRoute});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> with WidgetsBindingObserver {
  late GoRouter router;
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
    
    final biometricService = getIt<BiometricService>();
    final authenticated = await biometricService.authenticate();
    
    if (!authenticated) {
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
        // USAMOS LA INSTANCIA ÚNICA DE GETIT PARA QUE TODO ESTÉ SINCRONIZADO
        BlocProvider.value(value: getIt<TotalMoneyCubit>()),
        BlocProvider(create: (_) => DateCubit()),
        BlocProvider(create: (_) => IncomesCubit()),
        BlocProvider(create: (_) => ExpensesCubit()),
        // PASAMOS LA INSTANCIA DE GETIT TAMBIÉN AQUÍ
        BlocProvider(create: (_) => HistoryCubit(totalMoneyCubit: getIt<TotalMoneyCubit>())),
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
