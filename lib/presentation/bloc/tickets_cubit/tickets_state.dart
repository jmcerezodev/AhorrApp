part of 'tickets_cubit.dart';

enum TicketsStatus { initial, loading, success, failure }

class TicketsState extends Equatable {
  final TicketsStatus status;
  final List<TicketItem> items;
  final String? errorMessage;

  const TicketsState({
    this.status = TicketsStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.amount);

  TicketsState copyWith({
    TicketsStatus? status,
    List<TicketItem>? items,
    String? errorMessage,
  }) {
    return TicketsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
