import 'package:ahorrapp/config/routes/app_router.dart';
import 'package:ahorrapp/config/theme/app_theme.dart';
import 'package:ahorrapp/core/background/pending_ocr_worker.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/screens/security_lock_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy();

    await Preferences.init();
    await setupServiceLocator();

    getIt<SyncService>().init();

    // Motor de procesamiento diferido: ejecuta en background cuando hay red
    await _initWorkmanager();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final authService = getIt<AuthAppwrite>();
    String initialRoute = '/login';
    
    final bool hasActiveSession = Preferences.uId.isNotEmpty && Preferences.isLoggedIn;

    if (hasActiveSession) {
      initialRoute = '/home-screen';
    } else {
      initialRoute = await authService.getInitialRoute();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: getIt<ThemeCubit>()),
          BlocProvider.value(value: getIt<SecurityCubit>()),
        ],
        child: MainAppWrapper(initialRoute: initialRoute),
      )
    );
  } catch (e) {
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

/// Inicializa WorkManager y registra la tarea periódica de OCR diferido.
///
/// - [ExistingPeriodicWorkPolicy.keep]: si la tarea ya está encolada no se duplica.
/// - [NetworkType.connected]: la tarea solo corre cuando hay conexión activa.
/// - iOS extra: añade en `ios/Runner/Info.plist`:
///   <key>BGTaskSchedulerPermittedIdentifiers</key>
///   <array><string>processPendingOcrTicketsV2</string></array>
Future<void> _initWorkmanager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
  await Workmanager().registerPeriodicTask(
    kPendingOcrTaskId,
    kPendingOcrTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
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
  static const platform = MethodChannel('dev.jmcerezo.ahorrapp/security');

  late final TotalMoneyCubit _totalMoneyCubit;
  late final HistoryCubit _historyCubit;
  late final LoginCubit _loginCubit;
  late final ShoppingListCubit _shoppingCubit;
  late final ShoppingTemplatesCubit _templatesCubit;
  late final TicketsCubit _ticketsCubit;
  late final DebtsLoansCubit _debtsLoansCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    router = getAppRouter(widget.initialRoute);

    _totalMoneyCubit = getIt<TotalMoneyCubit>();
    _historyCubit = getIt<HistoryCubit>();
    _loginCubit = getIt<LoginCubit>();
    _shoppingCubit = getIt<ShoppingListCubit>();
    _templatesCubit = getIt<ShoppingTemplatesCubit>();
    _ticketsCubit = getIt<TicketsCubit>();
    _debtsLoansCubit = getIt<DebtsLoansCubit>();

    _updateAppSecurity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateAppSecurity();

    if (state == AppLifecycleState.paused) {
      context.read<SecurityCubit>().lock();
    }
  }

  Future<void> _updateAppSecurity() async {
    try {
      await platform.invokeMethod('setSecure', {'secure': Preferences.isBiometricActive});
    } on PlatformException catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicializamos Responsive aquí para que el tema pueda usar .sp, .w, etc.
    Responsive.init(context);

    final themeState = context.watch<ThemeCubit>().state;
    final securityStatus = context.watch<SecurityCubit>().state.status;

    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryCubit>.value(value: _historyCubit),
        BlocProvider<TotalMoneyCubit>.value(value: _totalMoneyCubit),
        BlocProvider<LoginCubit>.value(value: _loginCubit),
        BlocProvider<ShoppingListCubit>.value(value: _shoppingCubit),
        BlocProvider<ShoppingTemplatesCubit>.value(value: _templatesCubit),
        BlocProvider<TicketsCubit>.value(value: _ticketsCubit),
        BlocProvider<DebtsLoansCubit>.value(value: _debtsLoansCubit),

        BlocProvider(create: (_) => getIt<NewUserCubit>()),
        BlocProvider(create: (_) => getIt<ResetPasswordCubit>()),
        BlocProvider(create: (_) => getIt<UpdatePasswordCubit>()),
        BlocProvider(create: (_) => getIt<UpdateNameCubit>()),
        BlocProvider(create: (_) => getIt<DeleteAcountCubit>()),
        BlocProvider(create: (_) => getIt<SavingsCubit>()),
        BlocProvider(create: (_) => getIt<DateCubit>()),
        BlocProvider(create: (_) => getIt<IncomesCubit>()),
        BlocProvider(create: (_) => getIt<ExpensesCubit>()),
        BlocProvider(create: (_) => getIt<RecurrentExpensesCubit>()),
      ],
      child: MaterialApp.router(
        title: 'AhorrApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(isDarkMode: false),
        darkTheme: AppTheme().getTheme(isDarkMode: true),
        themeMode: themeState.themeMode,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              if (securityStatus == SecurityStatus.locked)
                const SecurityLockScreen(),
            ],
          );
        },
      ),
    );
  }
}
