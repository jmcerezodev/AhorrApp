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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TicketsCubit>().loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

          // 4. BARRA DE BÚSQUEDA
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => context.read<TicketsCubit>().updateSearchQuery(value),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Buscar por comercio o categoría...',
                  hintStyle: TextStyle(
                    fontSize: 13, 
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.w600
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.orange, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TicketsCubit>().updateSearchQuery('');
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.orange.withValues(alpha: 0.1), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.orange, width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // 5. LISTADO
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
