part of 'tickets_cubit.dart';

enum TicketsStatus { initial, loading, success, failure }

class TicketsState extends Equatable {
  final TicketsStatus status;
  final List<TicketItem> items;
  final String searchQuery;
  final String? errorMessage;

  const TicketsState({
    this.status = TicketsStatus.initial,
    this.items = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.amount);

  List<TicketItem> get filteredItems {
    if (searchQuery.isEmpty) return items;
    return items.where((item) {
      final nameLower = item.name.toLowerCase();
      final categoryLower = item.category.toLowerCase();
      final searchLower = searchQuery.toLowerCase();
      return nameLower.contains(searchLower) || categoryLower.contains(searchLower);
    }).toList();
  }

  TicketsState copyWith({
    TicketsStatus? status,
    List<TicketItem>? items,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TicketsState(
      status: status ?? this.status,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, searchQuery, errorMessage];
}
