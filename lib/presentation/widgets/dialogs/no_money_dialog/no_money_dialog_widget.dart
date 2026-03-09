import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NoMoneyDialog extends StatelessWidget {
  const NoMoneyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomDialogWrapper(
      // Mantenemos fidelidad visual con el color de borde original para advertencias
      borderColor: Colors.red.shade100,
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.money_off_rounded,
            color: Colors.red.shade400,
            title: 'SALDO INSUFICIENTE',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
            titleColor: Colors.blueGrey, // Fidelidad visual 1:1 con el color original
          ),
          const SizedBox(height: 15),
          
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
              color: Colors.orange.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
