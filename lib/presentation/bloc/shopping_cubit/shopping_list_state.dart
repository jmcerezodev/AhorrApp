part of 'shopping_list_cubit.dart';

enum ShoppingStatus { initial, loading, success, failure }

class ShoppingState extends Equatable {
  final List<ShoppingListItem> items;
  final ShoppingStatus status;
  final String? errorMessage;

  const ShoppingState({
    this.items = const [],
    this.status = ShoppingStatus.initial,
    this.errorMessage,
  });

  double get totalPrice => items.fold(0, (sum, item) => sum + item.amount);
  
  // Nuevo: Suma solo los productos que están marcados como comprados
  double get totalBoughtPrice => items
      .where((item) => item.isBought)
      .fold(0, (sum, item) => sum + item.amount);

  int get totalBought => items.where((item) => item.isBought).length;

  ShoppingState copyWith({
    List<ShoppingListItem>? items,
    ShoppingStatus? status,
    String? errorMessage,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [items, status, errorMessage];
}
