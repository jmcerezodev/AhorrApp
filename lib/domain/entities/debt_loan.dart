enum DebtLoanType { debt, loan }

class DebtLoan {
  final String id;
  final String userId;
  final String name;
  final String person; // Persona involucrada
  final double totalAmount;
  final double paidAmount;
  final DateTime? date; // Opcional
  final DateTime? dueDate;
  final DebtLoanType type;
  final String category;
  final bool isCompleted;
  
  // Plazos y Recurrencia
  final bool isInstallment; // Si se paga a plazos
  final int? totalInstallments; // Número total de meses/plazos
  final double? installmentAmount; // Cuota mensual
  final String? recurrentExpenseId; // Vinculación opcional con un gasto recurrente

  DebtLoan({
    required this.id,
    required this.userId,
    required this.name,
    required this.person,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.date,
    this.dueDate,
    required this.type,
    this.category = 'general',
    this.isCompleted = false,
    this.isInstallment = false,
    this.totalInstallments,
    this.installmentAmount,
    this.recurrentExpenseId,
  });

  double get remainingAmount => totalAmount - paidAmount;
  double get progress => totalAmount > 0 ? paidAmount / totalAmount : 0.0;
  
  // Cálculo de cuota sugerida basado en fecha de vencimiento o meses
  double calculateSuggestedInstallment(int months) {
    if (months <= 0) return totalAmount;
    return totalAmount / months;
  }

  DebtLoan copyWith({
    String? id,
    String? userId,
    String? name,
    String? person,
    double? totalAmount,
    double? paidAmount,
    DateTime? date,
    DateTime? dueDate,
    DebtLoanType? type,
    String? category,
    bool? isCompleted,
    bool? isInstallment,
    int? totalInstallments,
    double? installmentAmount,
    String? recurrentExpenseId,
  }) {
    return DebtLoan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      person: person ?? this.person,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isInstallment: isInstallment ?? this.isInstallment,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      recurrentExpenseId: recurrentExpenseId ?? this.recurrentExpenseId,
    );
  }
}
