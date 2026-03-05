import 'package:equatable/equatable.dart';

class ShoppingTemplate extends Equatable {
  final String id;
  final String userId;
  final String name;
  final List<ShoppingTemplateItem> items;

  const ShoppingTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
  });

  @override
  List<Object?> get props => [id, userId, name, items];
}

class ShoppingTemplateItem extends Equatable {
  final String name;
  final double amount;
  final String category;

  const ShoppingTemplateItem({
    required this.name,
    this.amount = 0.0,
    this.category = 'general',
  });

  @override
  List<Object?> get props => [name, amount, category];

  Map<String, dynamic> toJson() => {
    'name': name,
    'amount': amount,
    'category': category,
  };

  factory ShoppingTemplateItem.fromJson(Map<String, dynamic> json) => ShoppingTemplateItem(
    name: json['name'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    category: json['category'] ?? 'general',
  );
}
