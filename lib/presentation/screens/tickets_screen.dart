import 'package:ahorrapp/core/config/app_input_styles.dart';
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

class _TicketsScreenState extends State<TicketsScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<TicketsCubit>().loadItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si la app vuelve del segundo plano (donde pudo correr el worker), refrescamos
    if (state == AppLifecycleState.resumed) {
      context.read<TicketsCubit>().refreshListSilently();
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. APPBAR
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              from: 50.h,
              child: const TicketsAppBar()
            ),

            // 2. RESUMEN
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              from: 50.h,
              child: const TicketsSummaryWidget()
            ),

            // 3. BARRA DE PROGRESO
            BlocBuilder<TicketsCubit, TicketsState>(
              builder: (context, state) {
                // Se muestra si el estado es loading O si se está procesando OCR (ML Kit)
                final isLoading = state.status == TicketsStatus.loading || state.isProcessingOcr;
                
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      if (isLoading)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        )
                      else
                        const SizedBox(height: 2),
                    ],
                  ),
                );
              },
            ),

            // 4. BARRA DE BÚSQUEDA
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
                  decoration: AppInputStyles.decoration(
                    labelText: 'Buscador',
                    hintText: 'Buscar por comercio o categoría...',
                    prefixIcon: Icons.search_rounded,
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, size: 18.w),
                          onPressed: () {
                            _searchController.clear();
                            context.read<TicketsCubit>().updateSearchQuery('');
                          },
                        )
                      : null,
                  ),
                ),
              ),
            ),

            // 5. LISTADO
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 300),
                from: 50.h,
                child: const TicketsHistoryWidget()
              ),
            ),
          ],
        ),
      ),
    );
  }
}
