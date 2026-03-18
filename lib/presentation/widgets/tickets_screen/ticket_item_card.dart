import 'dart:io';
import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/usecases/tickets/transfer_tickets_to_expenses_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/ticket_export_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/tickets_dialogs/view_ticket_image_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class TicketItemCard extends StatelessWidget {
  final TicketItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const TicketItemCard({
    super.key,
    required this.item,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPendingOcr = item.ocrStatus == OcrStatus.pendingOcr;

    return GestureDetector(
      onTap: isPendingOcr ? null : () => _handleTap(context),
      onLongPress: isPendingOcr ? null : () => _showExportDialog(context),
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isPendingOcr ? 0.7 : 1.0,
        child: Container(
          constraints: BoxConstraints(minHeight: 80.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18.w),
            border: Border.all(
              color: isPendingOcr 
                ? colorScheme.primary.withValues(alpha: 0.2)
                : (item.isTransferred 
                    ? Colors.green.withValues(alpha: 0.2) 
                    : Colors.orange.withValues(alpha: 0.1)),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10.w,
                offset: Offset(0, 4.h),
              )
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40.w,
                    child: Row(
                      children: [
                        // 1. BOTÓN ACCIÓN
                        _AddExpenseButton(item: item),
                        
                        SizedBox(width: 12.w),

                        // 2. INFO DEL TICKET
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15.sp,
                                  color: colorScheme.onSurface,
                                  decoration: item.isTransferred ? TextDecoration.lineThrough : null,
                                  decorationColor: colorScheme.onSurface.withValues(alpha: 0.3),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded, 
                                    size: 10.sp, 
                                    color: colorScheme.onSurface.withValues(alpha: 0.4)
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(item.date),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Flexible(
                                    child: Text(
                                      item.category.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w900,
                                        color: isPendingOcr 
                                          ? colorScheme.primary.withValues(alpha: 0.7)
                                          : (item.isTransferred 
                                              ? Colors.green.withValues(alpha: 0.7) 
                                              : Colors.orange.withValues(alpha: 0.7)),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 10.w),

                        // 3. TOTAL
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isPendingOcr)
                              Row(
                                children: [
                                  Text(
                                    'Procesando...',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(Icons.hourglass_empty_rounded, size: 14.sp, color: colorScheme.primary),
                                ],
                              )
                            else
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: PrivacyAmountText(
                                  amount: '${humanizeNumbers.number(item.amount)}€',
                                  isPrivacyActive: context.watch<ThemeCubit>().state.isPrivacyModeActive,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16.sp,
                                    color: item.isTransferred 
                                      ? Colors.green.shade700 
                                      : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            SizedBox(height: 2.h),
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface.withValues(alpha: 0.3),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isPendingOcr)
                Positioned(
                  bottom: 0,
                  left: 18.w,
                  right: 18.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18.w),
                      bottomRight: Radius.circular(18.w),
                    ),
                    child: LinearProgressIndicator(
                      minHeight: 2.h,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (item.imagePath == null) {
      print('[TicketItemCard] imagePath es null para: ${item.name}');
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final storedPath = item.imagePath!;
    final fileName = storedPath.split('/').last;
    final resolvedPath = '${appDir.path}/$fileName';

    String? validPath;
    if (File(resolvedPath).existsSync()) {
      validPath = resolvedPath;
    } else if (File(storedPath).existsSync()) {
      validPath = storedPath;
    } else {
      print('[TicketItemCard] Archivo no encontrado. Ticket: ${item.name} | fileName: $fileName');
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => ViewTicketImageDialog(
          imagePath: validPath!,
          title: item.name,
        ),
      );
    }
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TicketExportDialog(item: item),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  final TicketItem item;
  const _AddExpenseButton({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isTransferred = item.isTransferred;
    final bool isPendingOcr = item.ocrStatus == OcrStatus.pendingOcr;

    return Container(
      decoration: BoxDecoration(
        color: isPendingOcr
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : (isTransferred 
              ? Colors.green.withValues(alpha: 0.1) 
              : Colors.orange.withValues(alpha: 0.1)),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: (isTransferred || isPendingOcr) ? null : () => _addTicketToExpenses(context),
        icon: Icon(
          isPendingOcr 
            ? Icons.sync_rounded
            : (isTransferred ? Icons.check_circle_rounded : Icons.add_task_rounded),
          color: isPendingOcr 
            ? Theme.of(context).colorScheme.primary
            : (isTransferred ? Colors.green : Colors.orange),
          size: 22.w,
        ),
        tooltip: isPendingOcr 
          ? 'Procesando OCR...' 
          : (isTransferred ? 'Ticket ya añadido' : 'Añadir a gastos'),
      ),
    );
  }

  Future<void> _addTicketToExpenses(BuildContext context) async {
    final ticketsCubit = context.read<TicketsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final dateCubit = context.read<DateCubit>();
    final navigator = Navigator.of(context);

    try {
      await getIt<TransferTicketsToExpensesUseCase>().call(
        userId: Preferences.uId,
        items: [item],
        asPack: false,
      );

      await ticketsCubit.updateItem(item.copyWith(isTransferred: true));

      final dateState = dateCubit.state;
      historyCubit.loadHistoryByDate(dateState.month, dateState.year);

      if (navigator.mounted) {
        showDialog(
          context: navigator.context,
          builder: (_) => SuccessfulDialogNoGo(
            title: '¡AÑADIDO!',
            sucessfulName: 'El ticket de "${item.name}" se ha añadido a tus gastos.',
          ),
        );
      }
    } catch (e) {
      if (navigator.mounted) {
        ScaffoldMessenger.of(navigator.context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir gasto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
