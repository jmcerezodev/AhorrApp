enum RecurrentFrequency { monthly, quarterly, semiAnnually, annually }

class RecurrentExpense {
  // ---------------------------------------------------------------------------
  // Helpers de fecha — viven en el dominio, no en la presentación
  // ---------------------------------------------------------------------------

  /// Suma [monthsDelta] meses a [baseYear]/[baseMonth] y devuelve un DateTime
  /// con [desiredDay] clampeado al último día del mes destino.
  /// Evita el overflow silencioso de Dart (ej. DateTime(2024, 4, 31) → mayo 1).
  static DateTime _clampedDate(
      int baseYear, int baseMonth, int desiredDay, int monthsDelta) {
    final totalMonths = baseYear * 12 + (baseMonth - 1) + monthsDelta;
    final targetYear = totalMonths ~/ 12;
    final targetMonth = (totalMonths % 12) + 1;
    final lastDay = DateTime(targetYear, targetMonth + 1, 0).day;
    return DateTime(targetYear, targetMonth, desiredDay.clamp(1, lastDay));
  }
  final String id;
  final String userId;
  final String name;
  final double amount;
  final int? day;
  final String category;
  final bool isActive;
  final String? lastApplied;
  final RecurrentFrequency frequency;
  final DateTime startDate; 
  final int position;
  final bool includeInSummary; 
  final bool isIncome; // NUEVO: Para distinguir entre ingreso y gasto recurrente

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
    this.includeInSummary = true,
    this.isIncome = false, // Por defecto es gasto
  });

  // ---------------------------------------------------------------------------
  // Propiedades computadas (fuente de verdad para la presentación)
  // ---------------------------------------------------------------------------

  int get _monthsPerCycle {
    switch (frequency) {
      case RecurrentFrequency.monthly:     return 1;
      case RecurrentFrequency.quarterly:   return 3;
      case RecurrentFrequency.semiAnnually: return 6;
      case RecurrentFrequency.annually:    return 12;
    }
  }

  /// Fecha del próximo cobro/ingreso.
  /// Retorna null si el gasto es manual (day == null).
  ///
  /// Ancla el cálculo en [startDate] para mantener el patrón original del ciclo
  /// (ej. un gasto anual que comienza en julio siempre cae en julio, no en el
  /// mes en que fue procesado por última vez).
  DateTime? get nextPaymentDate {
    if (day == null) return null;

    final now = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // 1. Avanzar desde startDate hasta igualar o superar "hoy"
    DateTime next = _clampedDate(startDate.year, startDate.month, day!, 0);
    while (next.isBefore(now)) {
      next = _clampedDate(next.year, next.month, day!, _monthsPerCycle);
    }

    // 2. Si este período exacto ya fue aplicado, saltar al siguiente ciclo
    if (lastApplied != null) {
      final parts = lastApplied!.split('-');
      final lastMonth = int.parse(parts[0]);
      final lastYear = int.parse(parts[1]);
      if (lastMonth == next.month && lastYear == next.year) {
        next = _clampedDate(next.year, next.month, day!, _monthsPerCycle);
      }
    }

    return next;
  }

  /// Progreso (0.0–1.0) dentro del ciclo actual, para la barra de progreso.
  double get cycleProgress {
    final next = nextPaymentDate;
    if (next == null || day == null) return 0.0;

    final now = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final prev = _clampedDate(next.year, next.month, day!, -_monthsPerCycle);

    final totalDays = next.difference(prev).inDays;
    if (totalDays <= 0) return 0.0;
    return (now.difference(prev).inDays / totalDays).clamp(0.0, 1.0);
  }

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
    bool? includeInSummary,
    bool? isIncome,
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
      includeInSummary: includeInSummary ?? this.includeInSummary,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
