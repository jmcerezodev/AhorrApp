import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/tickets_app_bar.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/tickets_history_widget.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/tickets_summary_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketsCubit>().loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. APPBAR
          const TicketsAppBar(),

          // 2. RESUMEN
          const TicketsSummaryWidget(),

          // 3. BOTONES DE ACCIÓN (Mismo estilo que Shopping List)
          BlocBuilder<TicketsCubit, TicketsState>(
            builder: (context, state) {
              final bool hasItems = state.items.isNotEmpty;
              
              return FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      // COLUMNA 1: LIMPIAR LISTA
                      Expanded(
                        child: _ActionButton(
                          onPressed: hasItems ? () => _showClearConfirmation(context) : null,
                          icon: Icons.delete_sweep_rounded,
                          label: 'LIMPIAR TODO',
                          color: Colors.red,
                        ),
                      ),
                      
                      const SizedBox(width: 10),

                      // COLUMNA 2: AÑADIR A GASTOS
                      Expanded(
                        child: _ActionButton(
                          onPressed: hasItems 
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<TicketsCubit>(),
                                    child: const TransferTicketToExpensesDialog(),
                                  ),
                                );
                              }
                            : null,
                          icon: Icons.receipt_long_rounded,
                          label: 'AÑADIR A GASTOS', // CAMBIADO: Coherencia con Shopping List
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. LISTADO
          const Expanded(
            child: TicketsHistoryWidget(),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (childContext) => const ClearTicketsDialog(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: FittedBox(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05),
          foregroundColor: isEnabled ? color : Colors.grey.withValues(alpha: 0.3),
          elevation: 0,
          side: BorderSide(
            color: isEnabled ? color : Colors.grey.withValues(alpha: 0.1), 
            width: 1.5
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
