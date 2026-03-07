import 'package:equatable/equatable.dart';

class ShoppingListItem extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount; // Cantidad o precio estimado
  final String category;
  final bool isBought;
  final int position;
  final int quantity;

  const ShoppingListItem({
    required this.id,
    required this.userId,
    required this.name,
    this.amount = 0.0,
    this.category = 'general',
    this.isBought = false,
    this.position = 0,
    this.quantity = 1,
  });

   ShoppingListItem copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? category,
    bool? isBought,
    int? position,
    int? quantity,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      isBought: isBought ?? this.isBought,
      position: position ?? this.position,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, amount, category, isBought, position, quantity];
}
