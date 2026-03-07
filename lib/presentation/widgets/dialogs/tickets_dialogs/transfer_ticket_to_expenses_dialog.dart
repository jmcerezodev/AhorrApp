import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/pack_config_ticket_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';

class TransferTicketToExpensesDialog extends StatelessWidget {
  const TransferTicketToExpensesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketsCubit = context.read<TicketsCubit>();
    final historyCubit = context.read<HistoryCubit>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Text(
            'AÑADIR A GASTOS',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
      content: const Text(
        '¿Cómo quieres guardar los productos del ticket en tu historial de gastos?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: 10,
      actions: [
        _DialogButton(
          label: 'TODO EN UN PACK',
          icon: Icons.inventory_2_rounded,
          onPressed: () {
            context.pop(); // Cerramos el de selección
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: ticketsCubit),
                  BlocProvider.value(value: historyCubit),
                ],
                child: const PackConfigTicketDialog(),
              ),
            );
          },
        ),
        _DialogButton(
          label: 'PRODUCTO A PRODUCTO',
          icon: Icons.list_alt_rounded,
          onPressed: () async {
            final navigator = Navigator.of(context);
            final dateState = context.read<DateCubit>().state;
            navigator.pop();

            try {
              await getIt<TransferTicketsToExpensesUseCase>().call(
                userId: Preferences.uId,
                items: ticketsCubit.state.items,
                asPack: false,
              );

              historyCubit.loadHistoryByDate(dateState.month, dateState.year);
              ticketsCubit.loadItems();

              if (navigator.mounted) {
                showDialog(
                  context: navigator.context, 
                  builder: (_) => const SuccessfulDialogNoGo(
                    title: '¡AÑADIDO!',
                    sucessfulName: 'Los productos se han añadido individualmente a tu historial correctamente.'
                  )
                );
              }
            } catch (e) {
              if (navigator.mounted) {
                ScaffoldMessenger.of(navigator.context).showSnackBar(
                  SnackBar(content: Text('Error al transferir: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCELAR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          foregroundColor: Colors.orange,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.orange, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
