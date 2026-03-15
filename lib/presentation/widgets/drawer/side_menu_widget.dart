import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../dialogs/export_dialogs/export_pdf_dialog.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state == ThemeMode.dark;
    final biometricService = BiometricService();
    final primaryOrange = Theme.of(context).primaryColor;
    
    // Detectamos si es pantalla pequeña (iPhone 7 altura aprox 667)
    final bool isSmallScreen = MediaQuery.of(context).size.height <= 700;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.w),
          bottomRight: Radius.circular(30.w),
        ),
      ),
      child: Column(
        children: [
          const _Header(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: 10.h),
                const _SyncButton(),
                SizedBox(height: 10.h),
                const _SectionTitle(title: 'AJUSTES DE LA APP'),
                
                _CustomSwitchItem(
                  leadingIcon: Icons.dark_mode_outlined,
                  label: 'Modo Oscuro',
                  value: isDark,
                  onChanged: (val) => themeCubit.toggleTheme(),
                  activeIcon: Icons.dark_mode_rounded,
                  inactiveIcon: Icons.light_mode_rounded,
                ),

                _CustomSwitchItem(
                  leadingIcon: Icons.fingerprint_rounded,
                  label: 'Biometría',
                  value: Preferences.isBiometricActive,
                  onChanged: (val) async {
                    if (val) {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => const BiometricInfoDialog(),
                      );
                      
                      if (confirmed == true) {
                        Preferences.isBiometricActive = true;
                        (context as Element).markNeedsBuild();
                      }
                    } else {
                      final bool authenticated = await biometricService.authenticate();
                      if (authenticated) {
                        Preferences.isBiometricActive = false;
                        (context as Element).markNeedsBuild();
                      }
                    }
                  },
                  activeIcon: Icons.fingerprint_rounded,
                  inactiveIcon: Icons.lock_outline_rounded,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
                  child: Divider(height: 1.h, thickness: 0.5, color: primaryOrange.withOpacity(0.3)),
                ),

                const _SectionTitle(title: 'GESTIÓN DE CUENTA'),
                _DrawerItem(
                  icon: Icons.badge_outlined,
                  label: 'Cambiar Nombre',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const UpdateNameDialog(title: 'Cambio de Nombre'),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.lock_reset_rounded,
                  label: 'Cambiar Contraseña',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const UpdatePasswordDialog(
                        title: 'Cambio de contraseña',
                        text: '',
                      ),
                    );
                  },
                ),

                _DrawerItem(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'Exportar Reporte (PDF)',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const ExportPdfDialog(),
                    );
                  },
                ),
                
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar Sesión',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const SingOutDialog(),
                    );
                  },
                ),

                _DrawerItem(
                  icon: Icons.no_accounts_rounded,
                  label: 'Eliminar Cuenta',
                  iconColor: Colors.red.shade300,
                  labelColor: Colors.red.shade300,
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => const DeleteAcountDialog(
                        title: 'Eliminar Cuenta',
                        text: 'Introduce tu contraseña para confirmar.',
                      ),
                    );
                  },
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
                  child: Divider(height: 1.h, thickness: 0.5, color: primaryOrange.withOpacity(0.3)),
                ),

                const _SectionTitle(title: 'INFORMACIÓN Y LEGAL'),
                _DrawerItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Licencias',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/licenses');
                  },
                ),
                _DrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacidad',
                  isSmallScreen: isSmallScreen,
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/privacy');
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          const SafeArea(
            top: false,
            child: _Footer(),
          ),
        ],
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: OutlinedButton.icon(
        onPressed: () => _showSyncDialog(context),
        icon: Icon(Icons.sync_rounded, size: 18.w),
        label: Text('SINCRONIZAR AHORA', style: TextStyle(fontSize: 11.sp, letterSpacing: 1)),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: BorderSide(color: primaryOrange.withOpacity(0.5)),
          minimumSize: Size(double.infinity, 45.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.w)),
          backgroundColor: isDark ? primaryOrange.withOpacity(0.05) : Colors.white,
        ),
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SyncStatusDialog(),
    ).then((_) {
      getIt<SyncService>().resetSyncStatus();
    });
    getIt<SyncService>().forceSync();
  }
}

class _SyncStatusDialog extends StatefulWidget {
  const _SyncStatusDialog();

  @override
  State<_SyncStatusDialog> createState() => _SyncStatusDialogState();
}

class _SyncStatusDialogState extends State<_SyncStatusDialog> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  final SyncService _syncService = getIt<SyncService>();

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _syncService.syncStatusNotifier.addListener(_onStatusChange);
  }

  @override
  void dispose() {
    _syncService.syncStatusNotifier.removeListener(_onStatusChange);
    _rotationController.dispose();
    super.dispose();
  }

  void _onStatusChange() {
    if (!mounted) return;
    final status = _syncService.syncStatusNotifier.value;
    if (status == SyncStatus.success || status == SyncStatus.error) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = Theme.of(context).primaryColor;

    return ValueListenableBuilder<SyncStatus>(
      valueListenable: _syncService.syncStatusNotifier,
      builder: (context, status, child) {
        IconData icon = Icons.sync_rounded;
        String title = 'Sincronizando...';
        String message = 'Estamos subiendo tus datos financieros a la nube segura.';
        Color iconColor = primaryOrange;

        if (status == SyncStatus.success) {
          icon = Icons.check_circle_outline_rounded;
          title = '¡Éxito!';
          message = 'Tus datos están sincronizados correctamente.';
          iconColor = Colors.green;
          _rotationController.stop();
        } else if (status == SyncStatus.error) {
          icon = Icons.error_outline_rounded;
          title = 'Error de conexión';
          message = 'No se ha podido sincronizar. Reintentando en unos momentos...';
          iconColor = Colors.orange;
          _rotationController.stop();
        }

        return CustomDialogWrapper(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: status == SyncStatus.syncing ? _rotationController : const AlwaysStoppedAnimation(0),
                child: Icon(icon, color: iconColor, size: 50.w),
              ),
              SizedBox(height: 20.h),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
              if (status == SyncStatus.success || status == SyncStatus.error) ...[
                SizedBox(height: 20.h),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CERRAR'),
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final primaryOrange = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.only(bottom: 25.h, top: 10.h),
      child: GestureDetector(
        onTap: () async {
          final Uri url = Uri.parse('https://jmcerezo.dev');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
        child: Column(
          children: [
            Text(
              'Desarrollado con ❤️ por',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade300,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'JMCEREZO.DEV',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: primaryOrange,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSwitchItem extends StatelessWidget {
  final IconData leadingIcon;
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _CustomSwitchItem({
    required this.leadingIcon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = Theme.of(context).primaryColor;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
      child: Row(
        children: [
          Icon(leadingIcon, color: primaryOrange, size: 20.w),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.blueGrey.shade800,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50.w,
              height: 28.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                color: value ? primaryOrange : (isDark ? Colors.white12 : Colors.grey.shade100),
                border: Border.all(
                  color: primaryOrange.withOpacity(0.3),
                  width: 1.5.w,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(2.0.w),
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      value ? activeIcon : inactiveIcon,
                      size: 13.w,
                      color: value ? primaryOrange : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15.w, 30.h, 15.w, 10.h),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        border: Border.all(color: primaryOrange.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.05),
            blurRadius: 10.w,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('assets/Logo.png', height: 45.h, fit: BoxFit.contain),
          SizedBox(height: 15.h),
          Text(
            Preferences.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.blueGrey.shade900,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            Preferences.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.blueGrey.shade400,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(25.w, 10.h, 25.w, 5.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          color: Colors.blueGrey.shade300,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool isSmallScreen;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = Theme.of(context).primaryColor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 1.h),
      child: ListTile(
        onTap: onTap,
        dense: true,
        // Ajustamos la densidad visual si la pantalla es pequeña (iPhone 7)
        visualDensity: isSmallScreen ? VisualDensity.compact : VisualDensity.standard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
        leading: Icon(icon, color: iconColor ?? primaryOrange, size: 20.w),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? (isDark ? Colors.white70 : Colors.blueGrey.shade800),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
