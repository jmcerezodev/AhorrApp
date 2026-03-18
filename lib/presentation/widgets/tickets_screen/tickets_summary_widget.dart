import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsSummaryWidget extends StatelessWidget {
  const TicketsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TicketsCubit, TicketsState>(
      builder: (context, state) {
        final bool isLoading = state.status == TicketsStatus.loading;
        final int totalItems = state.items.length;
        // ignore: avoid_print
        print('DEBUG_UI: Botón dibujado — status=${state.status} ocr=${state.isProcessingOcr}');

        return FadeInDown(
          duration: const Duration(milliseconds: 1000),
          from: 50.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                borderRadius: BorderRadius.circular(25.w),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3),
                  width: 1.5.w
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15.w,
                    offset: Offset(0, 8.h),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // COLUMNA 1: INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL ESCANEADOS',
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '$totalItems',
                              style: TextStyle(
                                color: isDark ? Colors.white : colorScheme.onSurface,
                                fontSize: Responsive.isSmallScreen ? 24.sp : 30.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),
                          
                          _DetectedChip(
                            isDark: isDark,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15.w),

                    // COLUMNA 2: BURBUJA DE ACCIÓN
                    _AddProductBubble(isLoading: isLoading),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddProductBubble extends StatelessWidget {
  final bool isLoading;
  const _AddProductBubble({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // HitTestBehavior.opaque: registra el toque en TODA el área del widget,
      // incluyendo zonas con color casi transparente (alpha 0.05 falla sin esto).
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // ignore: avoid_print
        print('¡CLICK REALIZADO! isLoading=$isLoading');
        context.read<TicketsCubit>().scanAndProcessTicket();
      },
      child: Container(
        width: 110.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLoading ? Icons.sync : Icons.qr_code_scanner_rounded,
              color: Colors.orange,
              size: 32.w,
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isLoading ? 'PROCESANDO' : 'ESCANEAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectedChip extends StatelessWidget {
  final bool isDark;
  final bool isLoading;

  const _DetectedChip({
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade400;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLoading ? Icons.hourglass_empty_rounded : Icons.receipt_long_rounded, 
            color: color.withValues(alpha: 0.8), 
            size: 12.w
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              isLoading ? 'ANALIZANDO...' : 'TICKETS',
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 8.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
