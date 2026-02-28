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
        initialRoute = '/login';
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

class _MainAppWrapperState extends State<MainAppWrapper> {
  late GoRouter router;
  // Creamos el totalMoneyCubit aquí para que sea persistente
  final totalMoneyCubit = TotalMoneyCubit();

  @override
  void initState() {
    super.initState();
    router = getAppRouter(widget.initialRoute);
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
