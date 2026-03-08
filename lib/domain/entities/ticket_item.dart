import 'package:equatable/equatable.dart';

class TicketItem extends Equatable {
  final String id;
  final String userId;
  final String name; // Nombre del establecimiento
  final double amount; // Total del ticket
  final String? imagePath;
  final DateTime date;
  final String category;
  final int position;

  const TicketItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
    this.imagePath,
    this.category = 'general',
    this.position = 0,
  });

  TicketItem copyWith({
    String? name,
    double? amount,
    DateTime? date,
    String? imagePath,
    String? category,
    int? position,
  }) {
    return TicketItem(
      id: id,
      userId: userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, amount, date, imagePath, category, position];
}
