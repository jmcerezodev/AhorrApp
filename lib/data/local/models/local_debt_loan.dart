import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:isar/isar.dart';

part 'local_debt_loan.g.dart';

@collection
class LocalDebtLoan {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String appwriteId;

  late String userId;
  late String name;
  late String person;
  late double totalAmount;
  late double paidAmount;
  DateTime? date;
  DateTime? dueDate;
  
  @enumerated
  late DebtLoanType type;
  
  late String category;
  late bool isCompleted;
  
  // Plazos y Recurrencia
  late bool isInstallment;
  int? totalInstallments;
  double? installmentAmount;
  String? recurrentExpenseId;

  // Convertir de Entidad a Modelo Isar
  static LocalDebtLoan fromEntity(DebtLoan entity) {
    return LocalDebtLoan()
      ..appwriteId = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..person = entity.person
      ..totalAmount = entity.totalAmount
      ..paidAmount = entity.paidAmount
      ..date = entity.date
      ..dueDate = entity.dueDate
      ..type = entity.type
      ..category = entity.category
      ..isCompleted = entity.isCompleted
      ..isInstallment = entity.isInstallment
      ..totalInstallments = entity.totalInstallments
      ..installmentAmount = entity.installmentAmount
      ..recurrentExpenseId = entity.recurrentExpenseId;
  }

  // Convertir de Modelo Isar a Entidad
  DebtLoan toEntity() {
    return DebtLoan(
      id: appwriteId,
      userId: userId,
      name: name,
      person: person,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      date: date,
      dueDate: dueDate,
      type: type,
      category: category,
      isCompleted: isCompleted,
      isInstallment: isInstallment,
      totalInstallments: totalInstallments,
      installmentAmount: installmentAmount,
      recurrentExpenseId: recurrentExpenseId,
    );
  }
}
