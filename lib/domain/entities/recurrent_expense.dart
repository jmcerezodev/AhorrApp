class RecurrentExpense {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int? day; // Ahora es opcional
  final String category;
  final bool isActive;
  final String? lastApplied; // Formato "MM-YYYY"

  RecurrentExpense({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    this.day,
    this.category = 'general',
    this.isActive = true,
    this.lastApplied,
  });
}
