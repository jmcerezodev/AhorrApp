import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/appwrite/appwrite_service.dart';
import 'appwrite_repository.dart';

class AuthAppwrite {
  final Account _account = AppwriteService().account;
  final LocalDbService _localDb = LocalDbService(); 
  final AppwriteRepository _appwriteRepo = AppwriteRepository();

  Future<String> getInitialRoute() async {
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
      
      Preferences.email = email;
      Preferences.password = password;
      
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
        url: 'https://jmcerezo.dev/reset-password-confirm',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> confirmResetPassword({
    required String userId, 
    required String secret, 
    required String password
  }) async {
    try {
      await _account.updateRecovery(
        userId: userId,
        secret: secret,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRemoteName(String name) async {
    try {
      await _account.updateName(name: name);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Actualiza la contraseña en Appwrite. 
  /// Lanza excepción si falla para que el Cubit la capture.
  Future<void> updatePasswordRemote(String newPassword, String oldPassword) async {
    await _account.updatePassword(password: newPassword, oldPassword: oldPassword);
    Preferences.password = newPassword;
  }

  Future deleteAcount(BuildContext context, {Function(double)? onProgress}) async {
    try {
      final String uid = Preferences.uId;

      final int totalDocs = await _appwriteRepo.getTotalDocsToDelete(uid);
      int deletedCount = 0;

      void updateProgress(int currentDeleted) {
        if (onProgress != null && totalDocs > 0) {
          onProgress(currentDeleted / totalDocs);
        }
      }

      await _appwriteRepo.deleteAllHistory(uid, onDeleted: (count) {
        deletedCount = count;
        updateProgress(deletedCount);
      });

      final int historyDeleted = deletedCount;
      await _appwriteRepo.deleteAllSavings(uid, onDeleted: (count) {
        deletedCount = historyDeleted + count;
        updateProgress(deletedCount);
      });
      
      await Preferences.clearAll();
      await _localDb.clearAll();

      _resetAllCubits(context);

      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {}
      
      if (context.mounted) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) => SuccessfulDialog(
            sucessfulName: 'Cuenta cerrada y datos eliminados',
            routeScreen: '/login',
            extraContent: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Si deseas borrar definitivamente tu correo y contraseña de nuestro sistema, por favor envía un correo a '),
                  TextSpan(
                    text: 'jmcerezodev@gmail.com',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'jmcerezodev@gmail.com',
                          query: 'subject=Solicitud de borrado de datos personales - AhorrApp',
                        );
                        if (await canLaunchUrl(emailLaunchUri)) {
                          await launchUrl(emailLaunchUri);
                        }
                      },
                  ),
                ],
              ),
            ),
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
        builder: (dialogContext) => const SuccessfulDialog(
          sucessfulName: 'Contraseña Cambiada',
          routeScreen: '/home-screen',
        ),
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
      await Preferences.clearAll();
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
