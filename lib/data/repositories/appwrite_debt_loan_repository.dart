import 'package:ahorrapp/core/config/env.dart';
import 'package:ahorrapp/core/appwrite/appwrite_service.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:appwrite/appwrite.dart';

class AppwriteDebtLoanRepository implements DebtLoanRepository {
  final Databases _databases;
  final String _databaseId = Env.appwriteDatabaseId;
  final String _collectionId = Env.debtsLoansCollectionId;

  // Refactorizamos para permitir inyectar el servicio de bases de datos
  AppwriteDebtLoanRepository({Databases? databases}) 
    : _databases = databases ?? AppwriteService().databases;

  @override
  Future<List<DebtLoan>> getDebtsLoans(String userId) async {
    final response = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _collectionId,
      queries: [Query.equal('userId', [userId])],
    );

    return response.documents.map((doc) {
      return DebtLoan(
        id: doc.$id,
        userId: doc.data['userId'],
        name: doc.data['name'],
        person: doc.data['person'],
        totalAmount: (doc.data['totalAmount'] as num).toDouble(),
        paidAmount: (doc.data['paidAmount'] as num).toDouble(),
        date: doc.data['date'] != null ? DateTime.parse(doc.data['date']) : null,
        dueDate: doc.data['dueDate'] != null ? DateTime.parse(doc.data['dueDate']) : null,
        type: doc.data['type'] == 'debt' ? DebtLoanType.debt : DebtLoanType.loan,
        category: doc.data['category'] ?? 'general',
        isCompleted: doc.data['isCompleted'] ?? false,
        isInstallment: doc.data['isInstallment'] ?? false,
        totalInstallments: doc.data['totalInstallments'],
        installmentAmount: doc.data['installmentAmount'] != null ? (doc.data['installmentAmount'] as num).toDouble() : null,
        recurrentExpenseId: doc.data['recurrentExpenseId'],
      );
    }).toList();
  }

  @override
  Future<void> addDebtLoan(DebtLoan debtLoan) async {
    await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: debtLoan.id,
      data: {
        'userId': debtLoan.userId,
        'name': debtLoan.name,
        'person': debtLoan.person,
        'totalAmount': debtLoan.totalAmount,
        'paidAmount': debtLoan.paidAmount,
        'date': debtLoan.date?.toIso8601String(),
        'dueDate': debtLoan.dueDate?.toIso8601String(),
        'type': debtLoan.type == DebtLoanType.debt ? 'debt' : 'loan',
        'category': debtLoan.category,
        'isCompleted': debtLoan.isCompleted,
        'isInstallment': debtLoan.isInstallment,
        'totalInstallments': debtLoan.totalInstallments,
        'installmentAmount': debtLoan.installmentAmount,
        'recurrentExpenseId': debtLoan.recurrentExpenseId,
      },
    );
  }

  @override
  Future<void> updateDebtLoan(DebtLoan debtLoan) async {
    await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: debtLoan.id,
      data: {
        'name': debtLoan.name,
        'person': debtLoan.person,
        'totalAmount': debtLoan.totalAmount,
        'paidAmount': debtLoan.paidAmount,
        'date': debtLoan.date?.toIso8601String(),
        'dueDate': debtLoan.dueDate?.toIso8601String(),
        'type': debtLoan.type == DebtLoanType.debt ? 'debt' : 'loan',
        'category': debtLoan.category,
        'isCompleted': debtLoan.isCompleted,
        'isInstallment': debtLoan.isInstallment,
        'totalInstallments': debtLoan.totalInstallments,
        'installmentAmount': debtLoan.installmentAmount,
        'recurrentExpenseId': debtLoan.recurrentExpenseId,
      },
    );
  }

  @override
  Future<void> deleteDebtLoan(String id) async {
    await _databases.deleteDocument(
      databaseId: _databaseId,
      collectionId: _collectionId,
      documentId: id,
    );
  }
}
