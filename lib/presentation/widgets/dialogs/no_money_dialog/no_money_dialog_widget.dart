import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoMoneyDialog extends StatelessWidget {
  const NoMoneyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.money_off_rounded,
            color: Colors.red.shade400,
            title: 'Saldo Insuficiente',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          AppDialogs.dialogMessage(
            'No tienes suficiente saldo disponible para realizar este gasto. Por favor, revisa tus ahorros o ingresos.',
            colorScheme,
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: AppDialogs.dialogPrimaryButton(
              text: 'ENTENDIDO',
              onPressed: () => context.pop(),
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
