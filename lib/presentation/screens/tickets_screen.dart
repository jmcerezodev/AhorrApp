import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
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
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: const TicketsAppBar()
          ),

          // 2. RESUMEN
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: const TicketsSummaryWidget()
          ),

          // 3. BARRA DE PROGRESO (Solo en carga)
          BlocBuilder<TicketsCubit, TicketsState>(
            builder: (context, state) {
              if (state.status != TicketsStatus.loading) return const SizedBox.shrink();
              
              return FadeIn(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 6,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Procesando ticket...',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. LISTADO
          Expanded(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: const TicketsHistoryWidget()
            ),
          ),
        ],
      ),
    );
  }
}
