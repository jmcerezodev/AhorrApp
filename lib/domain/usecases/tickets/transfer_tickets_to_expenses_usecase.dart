import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:uuid/uuid.dart';

class TransferTicketsToExpensesUseCase {
  final SaveMovementUseCase saveMovementUseCase;

  TransferTicketsToExpensesUseCase({
    required this.saveMovementUseCase,
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
      final double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
      final String finalName = packName ?? (items.isNotEmpty ? items.first.name : 'Compra Ticket');
      
      // Para packs, vinculamos al primer ticket si existe, 
      // o a una lista de IDs si fuera necesario en el futuro.
      final String? mainTicketId = items.length == 1 ? items.first.id : null;

      final packMovement = Movement(
        id: const Uuid().v4(),
        name: finalName,
        amount: totalAmount,
        type: MovementType.expense,
        isIncome: false,
        date: dateStr,
        hour: hourStr,
        month: month,
        year: now.year,
        createdAt: now,
        category: items.isNotEmpty ? items.first.category : 'general',
        ticketId: mainTicketId,
      );

      await saveMovementUseCase(packMovement);
    } else {
      for (var item in items) {
        final itemMovement = Movement(
          id: const Uuid().v4(),
          name: item.name,
          amount: item.amount,
          type: MovementType.expense,
          isIncome: false,
          date: dateStr,
          hour: hourStr,
          month: month,
          year: now.year,
          createdAt: now,
          category: item.category,
          ticketId: item.id,
        );
        
        await saveMovementUseCase(itemMovement);
      }
    }
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
