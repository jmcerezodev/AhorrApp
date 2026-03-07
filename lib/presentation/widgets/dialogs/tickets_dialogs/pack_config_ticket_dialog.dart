import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PackConfigTicketDialog extends StatefulWidget {
  const PackConfigTicketDialog({super.key});

  @override
  State<PackConfigTicketDialog> createState() => _PackConfigTicketDialogState();
}

class _PackConfigTicketDialogState extends State<PackConfigTicketDialog> {
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Compra Ticket');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ticketsCubit = context.watch<TicketsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final humanizeNumbers = HumanizeNumbers();

    return CustomDialogWrapper(
      horizontalInsetPadding: 20,
      borderColor: Colors.orange.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.inventory_2_rounded, 
            color: Colors.orange, 
            title: 'CONFIGURAR PACK',
            circularBackground: false,
            iconSize: 40,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          AppDialogs.dialogMessage('Indica un nombre para el pack de gastos del ticket.', colorScheme),
          const SizedBox(height: 20),
          
          CustomInputTextWidget(
            controller: _nameController,
            label: 'Nombre del Pack',
            hintText: 'Ej: Compra Mercadona',
            enabled: !_isLoading,
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL DEL TICKET', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.orange)),
                Text(
                  '${humanizeNumbers.number(ticketsCubit.state.totalAmount)}€',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: Text(
                    'CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.w900, 
                      fontSize: 12,
                      letterSpacing: 1
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'GUARDAR',
                  color: Colors.orange,
                  onPressed: _isLoading ? null : () => _handleTransfer(ticketsCubit, historyCubit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleTransfer(TicketsCubit ticketsCubit, HistoryCubit historyCubit) async {
    setState(() => _isLoading = true);
    final packName = _nameController.text.trim().isEmpty ? 'Compra Ticket' : _nameController.text.trim();
    final navigator = Navigator.of(context);

    try {
      final dateState = context.read<DateCubit>().state;

      await getIt<TransferTicketsToExpensesUseCase>().call(
        userId: Preferences.uId,
        items: ticketsCubit.state.items,
        asPack: true,
        packName: packName,
      );

      historyCubit.loadHistoryByDate(dateState.month, dateState.year);
      ticketsCubit.loadItems();

      navigator.pop();

      if (mounted) {
        showDialog(
          context: navigator.context, 
          builder: (_) => SuccessfulDialogNoGo(
            title: '¡AÑADIDO!',
            sucessfulName: 'La compra \'$packName\' se ha añadido a tu historial correctamente.'
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al transferir: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
