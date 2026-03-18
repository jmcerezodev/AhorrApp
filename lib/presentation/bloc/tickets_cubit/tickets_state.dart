part of 'tickets_cubit.dart';

enum TicketsStatus { initial, loading, success, failure }

class TicketsState extends Equatable {
  final TicketsStatus status;
  final List<TicketItem> items;
  final String searchQuery;
  final String? errorMessage;
  final bool isProcessingOcr;

  const TicketsState({
    this.status = TicketsStatus.initial,
    this.items = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.isProcessingOcr = false,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.amount);

  List<TicketItem> get filteredItems {
    final List<TicketItem> list = searchQuery.isEmpty 
      ? List<TicketItem>.from(items)
      : items.where((item) {
          final nameLower = item.name.toLowerCase();
          final categoryLower = item.category.toLowerCase();
          final searchLower = searchQuery.toLowerCase();
          return nameLower.contains(searchLower) || categoryLower.contains(searchLower);
        }).toList();

    // Ordenar por fecha descendente: los últimos escaneados aparecen primero
    list.sort((a, b) => b.date.compareTo(a.date));
    
    return list;
  }

  TicketsState copyWith({
    TicketsStatus? status,
    List<TicketItem>? items,
    String? searchQuery,
    String? errorMessage,
    bool? isProcessingOcr,
  }) {
    return TicketsState(
      status: status ?? this.status,
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      isProcessingOcr: isProcessingOcr ?? this.isProcessingOcr,
    );
  }

  @override
  List<Object?> get props => [status, items, searchQuery, errorMessage, isProcessingOcr];
}
