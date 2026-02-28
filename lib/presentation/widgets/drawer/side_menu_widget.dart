import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideMenuWidget extends StatelessWidget {
  const SideMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state == ThemeMode.dark;

    return NavigationDrawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      indicatorColor: Colors.orange.shade100,
      children: [
        const _Header(),
        const SizedBox(height: 5),
        
        const _SectionTitle(title: 'AJUSTES DE LA APP'),
        
        _DrawerSwitch(
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          label: 'Modo Oscuro',
          value: isDark,
          onChanged: (val) => themeCubit.toggleTheme(),
        ),

        _DrawerSwitch(
          icon: Icons.fingerprint_rounded,
          label: 'Seguridad Biométrica',
          value: Preferences.isBiometricActive,
          onChanged: (val) {
            Preferences.isBiometricActive = val;
            (context as Element).markNeedsBuild();
          },
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Divider(height: 1, thickness: 0.5, color: Colors.orange),
        ),

        const _SectionTitle(title: 'GESTIÓN DE CUENTA'),
        _DrawerItem(
          icon: Icons.badge_outlined,
          label: 'Cambiar Nombre',
          onTap: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => const UpdateNameDialog(title: 'Cambio de Nombre'),
          ),
        ),
        _DrawerItem(
          icon: Icons.lock_reset_rounded,
          label: 'Cambiar Contraseña',
          onTap: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => const UpdatePasswordDialog(
              title: 'Cambio de contraseña',
              text: '',
            ),
          ),
        ),
        
        _DrawerItem(
          icon: Icons.no_accounts_rounded,
          label: 'Eliminar Cuenta',
          iconColor: Colors.red.shade300,
          labelColor: Colors.red.shade300,
          onTap: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => const DeleteAcountDialog(
              title: 'Eliminar Cuenta',
              text: 'Introduce tu contraseña para confirmar.',
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Divider(height: 1, thickness: 0.5, color: Colors.orange),
        ),

        const _SectionTitle(title: 'INFORMACIÓN Y LEGAL'),
        _DrawerItem(
          icon: Icons.verified_user_outlined,
          label: 'Licencias',
          onTap: () => context.push('/licenses'),
        ),
        _DrawerItem(
          icon: Icons.privacy_tip_outlined,
          label: 'Política de Privacidad',
          onTap: () {},
        ),

        const SizedBox(height: 20),
        
        _DrawerItem(
          icon: Icons.logout_rounded,
          label: 'Cerrar Sesión',
          iconColor: Colors.blueGrey.shade600,
          onTap: () => showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => const SingOutDialog(),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _DrawerSwitch extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _DrawerSwitch({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade400, size: 20),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.blueGrey.shade800,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.7, // Ajuste para hacer el switch más pequeño
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.orange,
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
      margin: const EdgeInsets.fromLTRB(15, 30, 15, 10),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Padding reducido
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
          Image.asset('assets/Logo.png', height: 45, fit: BoxFit.contain), // Logo reducido
          const SizedBox(height: 15),
          Text(
            Preferences.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.blueGrey.shade900,
              fontSize: 16, // Fuente ligeramente reducida
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
