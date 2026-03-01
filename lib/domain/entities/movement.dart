enum MovementType { income, expense, saving }

class Movement {
  final String id;
  final String name;
  final double amount;
  final MovementType type;
  final bool isIncome;
  final String date;
  final String hour;
  final String month;
  final int year;
  final DateTime createdAt;
  final bool isSpent;

  Movement({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.isIncome,
    required this.date,
    required this.hour,
    required this.month,
    required this.year,
    required this.createdAt,
    this.isSpent = false,
  });

  // Helper para saber si es un ahorro activo
  bool get isActiveSaving => type == MovementType.saving && !isSpent;
}
