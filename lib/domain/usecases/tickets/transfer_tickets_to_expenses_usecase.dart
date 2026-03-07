import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/clear_tickets_usecase.dart';
import 'package:uuid/uuid.dart';

class TransferTicketsToExpensesUseCase {
  final SaveMovementUseCase saveMovementUseCase;
  final ClearTicketsUseCase clearTicketsUseCase;

  TransferTicketsToExpensesUseCase({
    required this.saveMovementUseCase,
    required this.clearTicketsUseCase,
  });

  Future<void> call({
    required String userId,
    required List<TicketItem> items,
    required bool asPack,
    String? packName,
  }) async {
    if (items.isEmpty) return;

    final now = DateTime.now();
    final String month = _getMonthName(now.month);
    final String dateStr = _getFormattedDate(now);
    final String hourStr = _getFormattedHour(now);

    if (asPack) {
      final double totalAmount = items.fold(0, (sum, item) => sum + (item.amount * item.quantity));
      
      final packMovement = Movement(
        id: const Uuid().v4(),
        name: packName ?? 'Compra Ticket',
        amount: totalAmount,
        type: MovementType.expense,
        isIncome: false,
        date: dateStr,
        hour: hourStr,
        month: month,
        year: now.year,
        createdAt: now,
        category: 'general',
      );

      await saveMovementUseCase(packMovement);
    } else {
      for (var item in items) {
        final itemMovement = Movement(
          id: const Uuid().v4(),
          name: item.name,
          amount: item.amount * item.quantity,
          type: MovementType.expense,
          isIncome: false,
          date: dateStr,
          hour: hourStr,
          month: month,
          year: now.year,
          createdAt: now,
          category: item.category,
        );
        
        await saveMovementUseCase(itemMovement);
      }
    }

    // Al terminar la transferencia, limpiamos la lista de tickets
    await clearTicketsUseCase(userId);
  }

  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getFormattedHour(DateTime date) {
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }
}
