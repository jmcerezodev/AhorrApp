enum RecurrentFrequency { monthly, quarterly, semiAnnually, annually }

class RecurrentExpense {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int? day;
  final String category;
  final bool isActive;
  final String? lastApplied;
  final RecurrentFrequency frequency;
  final DateTime startDate; // NUEVO: Fecha de referencia para el ciclo
  final int position; // NUEVO: Para organización manual

  RecurrentExpense({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    this.day,
    this.category = 'general',
    this.isActive = true,
    this.lastApplied,
    this.frequency = RecurrentFrequency.monthly,
    required this.startDate,
    this.position = 0,
  });

  RecurrentExpense copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    int? day,
    String? category,
    bool? isActive,
    String? lastApplied,
    RecurrentFrequency? frequency,
    DateTime? startDate,
    int? position,
  }) {
    return RecurrentExpense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      day: day ?? this.day,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      lastApplied: lastApplied ?? this.lastApplied,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      position: position ?? this.position,
    );
  }
}
