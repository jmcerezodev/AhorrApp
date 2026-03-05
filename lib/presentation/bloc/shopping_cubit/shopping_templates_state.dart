part of 'shopping_templates_cubit.dart';

enum ShoppingTemplatesStatus { initial, loading, success, failure }

class ShoppingTemplatesState extends Equatable {
  final List<ShoppingTemplate> templates;
  final ShoppingTemplatesStatus status;
  final String? errorMessage;

  const ShoppingTemplatesState({
    this.templates = const [],
    this.status = ShoppingTemplatesStatus.initial,
    this.errorMessage,
  });

  // Helper para saber si un producto ya es favorito
  bool isFavorite(String productName) {
    return templates.any((t) => t.name.toLowerCase() == productName.toLowerCase());
  }

  // Nuevo: Obtener el ID del favorito por su nombre para poder eliminarlo
  String? getFavoriteId(String productName) {
    try {
      return templates.firstWhere((t) => t.name.toLowerCase() == productName.toLowerCase()).id;
    } catch (_) {
      return null;
    }
  }

  ShoppingTemplatesState copyWith({
    List<ShoppingTemplate>? templates,
    ShoppingTemplatesStatus? status,
    String? errorMessage,
  }) {
    return ShoppingTemplatesState(
      templates: templates ?? this.templates,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [templates, status, errorMessage];
}
