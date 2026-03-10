import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_debt_loan.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:isar/isar.dart';

class IsarDebtLoanRepository implements DebtLoanRepository {
  final LocalDbService localDbService;

  IsarDebtLoanRepository(this.localDbService);

  @override
  Future<List<DebtLoan>> getDebtsLoans(String userId) async {
    final localItems = await localDbService.getDebtLoans(userId);
    return localItems.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addDebtLoan(DebtLoan debtLoan) async {
    final isar = localDbService.isar;
    
    await isar.writeTxn(() async {
      final existingItem = await isar.localDebtLoans
          .filter()
          .appwriteIdEqualTo(debtLoan.id)
          .findFirst();

      final localItem = LocalDebtLoan.fromEntity(debtLoan);
      if (existingItem != null) {
        localItem.id = existingItem.id;
      }
      await isar.localDebtLoans.put(localItem);
    });
  }

  @override
  Future<void> updateDebtLoan(DebtLoan debtLoan) async {
    final isar = localDbService.isar;
    
    await isar.writeTxn(() async {
      final existingItem = await isar.localDebtLoans
          .filter()
          .appwriteIdEqualTo(debtLoan.id)
          .findFirst();

      if (existingItem != null) {
        final updatedItem = LocalDebtLoan.fromEntity(debtLoan)..id = existingItem.id;
        await isar.localDebtLoans.put(updatedItem);
      }
    });
  }

  @override
  Future<void> deleteDebtLoan(String id) async {
    await localDbService.deleteDebtLoanByAppwriteId(id);
  }
  
  // Nuevo método para guardado masivo durante sincronización completa
  Future<void> saveAll(List<DebtLoan> items) async {
    final localItems = items.map((e) => LocalDebtLoan.fromEntity(e)).toList();
    await localDbService.saveDebtLoans(localItems);
  }
}
