import 'package:ahorrapp/core/auth/biometric_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state == ThemeMode.dark;
    final biometricService = BiometricService();

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
                const SizedBox(height: 10),
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Divider(height: 1, thickness: 0.5, color: Colors.orange),
                ),

                const _SectionTitle(title: 'GESTIÓN DE CUENTA'),
                _DrawerItem(
                  icon: Icons.badge_outlined,
                  label: 'Cambiar Nombre',
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
                  icon: Icons.logout_rounded,
                  label: 'Cerrar Sesión',
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
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Divider(height: 1, thickness: 0.5, color: Colors.orange),
                ),

                const _SectionTitle(title: 'INFORMACIÓN Y LEGAL'),
                _DrawerItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Licencias',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/licenses');
                  },
                ),
                _DrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Política de Privacidad',
                  onTap: () {},
                ),
                const SizedBox(height: 20),
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

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, top: 10),
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
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade300,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'JMCEREZO.DEV',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.orange.shade400,
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        children: [
          Icon(leadingIcon, color: Colors.orange.shade400, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.blueGrey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? Colors.orange.shade400 : Colors.grey.shade100,
                border: Border.all(
                  color: Colors.orange.shade300.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      value ? activeIcon : inactiveIcon,
                      size: 13,
                      color: value ? Colors.orange.shade700 : Colors.grey.shade400,
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(15, 30, 15, 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.shade100.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset('assets/Logo.png', height: 45, fit: BoxFit.contain),
          const SizedBox(height: 15),
          Text(
            Preferences.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.blueGrey.shade900,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Preferences.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.blueGrey.shade400,
              fontSize: 12,
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
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9,
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

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor ?? Colors.orange.shade400, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? (isDark ? Colors.white70 : Colors.blueGrey.shade800),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
