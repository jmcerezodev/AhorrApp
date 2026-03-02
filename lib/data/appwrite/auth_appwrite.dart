import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/error_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/appwrite/appwrite_service.dart';
import 'appwrite_repository.dart';

class AuthAppwrite {
  final Account _account = AppwriteService().account;
  final LocalDbService _localDb = LocalDbService(); 

  Future<String> getInitialRoute() async {
    // REGLA MAESTRA: Si el usuario ya validó red, vamos a Home (Modo Offline)
    if (Preferences.isLoggedIn && Preferences.uId.isNotEmpty) {
      return '/home-screen';
    }

    try {
      final user = await _account.get();
      Preferences.uId = user.$id;
      Preferences.name = user.name;
      Preferences.email = user.email;
      Preferences.isLoggedIn = true;
      return '/home-screen';
    } catch (e) {
      return '/login';
    }
  }

  Future createAcount(String email, String password, String name) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      
      await _account.createEmailPasswordSession(email: email, password: password);
      
      Preferences.uId = user.$id;
      Preferences.name = user.name;
      Preferences.email = user.email;
      Preferences.isLoggedIn = true;
      
      return user.$id;
    } on AppwriteException catch (e) {
      if (e.code == 409) return 1;
      return 3;
    }
  }

  Future signInEmailAndPassword(String email, String password) async {
    try {
      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}

      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      
      final user = await _account.get();
      
      Preferences.uId = user.$id;
      Preferences.name = user.name;
      Preferences.email = user.email;
      Preferences.isLoggedIn = true;
      
      if (Preferences.isRemember) {
        Preferences.email = email;
        Preferences.password = password;
      }
      
      return user.$id;
    } on AppwriteException catch (e) {
      if (e.code == 401 || e.code == 400) return 0;
      return 3;
    } catch (e) {
      return 3;
    }
  }

  Future resetPassword(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'http://62.171.133.118:8081/v1/auth/recovery',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future deleteAcount(BuildContext context) async {
    try {
      Preferences.uId = ''; 
      Preferences.name = '';
      Preferences.isLoggedIn = false;

      _resetAllCubits(context);

      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}
      await _localDb.clearAll();
      
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => const SuccessfulDialog(
            sucessfulName: 'Cuenta cerrada y datos eliminados',
            routeScreen: '/login',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => const ErrorDialog(),
        );
      }
    }
  }

  Future updatePassword(BuildContext context, String newPassword, String oldPassword) async {
    try {
      await _account.updatePassword(password: newPassword, oldPassword: oldPassword);
      Preferences.password = newPassword;

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => const SuccessfulDialogNoGo(sucessfulName: 'Contraseña Cambiada'),
      );
    } catch (e) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => const ErrorDialog(
          errorMessage: '!Se ha producido un Error!\n La contraseña no ha cambiado',
        ),
      );
    }
  }

  Future<void> singOut(BuildContext context) async {
    try {
      Preferences.uId = '';
      Preferences.name = '';
      Preferences.isLoggedIn = false;
      
      _resetAllCubits(context);

      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}
      await _localDb.clearAll();
      
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => const SuccessfulDialog(
            sucessfulName: 'Se ha cerrado la sesión',
            routeScreen: '/login',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => const ErrorDialog(
            errorMessage: '!Se ha producido un Error!\n La sesión no se ha cerrado',
          ),
        );
      }
    }
  }

  void _resetAllCubits(BuildContext context) {
    try {
      context.read<DateCubit>().resetCubit();
      context.read<TotalMoneyCubit>().resetCubit();
      context.read<HistoryCubit>().resetCubit();
      context.read<SavingsCubit>().resetCubit();
      context.read<LoginCubit>().resetCubit();
      context.read<UpdateNameCubit>().resetCubit();
    } catch (e) {}
  }

  Future<void> checkUserAuthentication(BuildContext context) async {
    if (Preferences.isLoggedIn) return;
    try {
      final user = await _account.get();
      Preferences.name = user.name;
    } catch (e) {
      context.go('/login');
    }
  }
}
