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
  });
}
