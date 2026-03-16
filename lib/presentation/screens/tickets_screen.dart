import 'package:ahorrapp/core/config/responsive_utils.dart';
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
    Responsive.init(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. APPBAR (FIJO)
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            from: 50.h,
            child: const TicketsAppBar()
          ),

          // 2. RESUMEN (FIJO)
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            from: 50.h,
            child: const TicketsSummaryWidget()
          ),

          // 3. BARRA DE PROGRESO (Solo en carga - FIJO)
          BlocBuilder<TicketsCubit, TicketsState>(
            builder: (context, state) {
              if (state.status != TicketsStatus.loading) return const SizedBox.shrink();
              
              return FadeIn(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        minHeight: 6.h,
                        borderRadius: BorderRadius.all(Radius.circular(10.w)),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Procesando ticket...',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 11.sp,
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

          // 4. BARRA DE BÚSQUEDA (FIJO)
          FadeInDown(
            delay: const Duration(milliseconds: 200),
            from: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w, 
                vertical: isSmallScreen ? 5.h : 10.h
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => context.read<TicketsCubit>().updateSearchQuery(value),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Buscar por comercio o categoría...',
                  hintStyle: TextStyle(
                    fontSize: 13.sp, 
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontWeight: FontWeight.w600
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.orange, size: 20.w),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, size: 18.w),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TicketsCubit>().updateSearchQuery('');
                        },
                      )
                    : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.withValues(alpha: 0.05),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.w),
                    borderSide: BorderSide(color: Colors.orange.withValues(alpha: 0.1), width: 1.w),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.w),
                    borderSide: BorderSide(color: Colors.orange, width: 1.5.w),
                  ),
                ),
              ),
            ),
          ),

          // 5. LISTADO (SCROLLABLE INDEPENDIENTE)
          Expanded(
            child: FadeInUp(
              delay: const Duration(milliseconds: 300),
              from: 50.h,
              child: const TicketsHistoryWidget()
            ),
          ),
        ],
      ),
    );
  }
}
