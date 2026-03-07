import 'package:equatable/equatable.dart';

class TicketItem extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int quantity;
  final String category;
  final int position;

  const TicketItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.quantity,
    required this.category,
    this.position = 0,
  });

  TicketItem copyWith({
    String? name,
    double? amount,
    int? quantity,
    String? category,
    int? position,
  }) {
    return TicketItem(
      id: id,
      userId: userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, amount, quantity, category, position];
}
