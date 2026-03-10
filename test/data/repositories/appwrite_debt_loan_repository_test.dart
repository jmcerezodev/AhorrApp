import 'package:ahorrapp/data/repositories/appwrite_debt_loan_repository.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabases extends Mock implements Databases {}

void main() {
  late AppwriteDebtLoanRepository repository;
  late MockDatabases mockDatabases;

  setUp(() {
    mockDatabases = MockDatabases();
    // Inyectamos el mock directamente para evitar la inicialización del cliente real
    repository = AppwriteDebtLoanRepository(databases: mockDatabases);
  });

  group('AppwriteDebtLoanRepository Test -', () {
    final tDebt = DebtLoan(
      id: '1', userId: 'u1', name: 'N', person: 'P', 
      totalAmount: 100, paidAmount: 0, type: DebtLoanType.debt
    );

    test('getDebtsLoans debe retornar lista de entidades desde Appwrite', () async {
      final mockDocList = models.DocumentList(
        total: 1, 
        documents: [
          models.Document(
            $id: '1', 
            $collectionId: 'c', 
            $databaseId: 'd', 
            $createdAt: '', 
            $updatedAt: '', 
            $permissions: [], 
            $sequence: 0,
            data: {
              'userId': 'u1',
              'name': 'N',
              'person': 'P',
              'totalAmount': 100,
              'paidAmount': 0,
              'type': 'debt',
              'isCompleted': false,
              'isInstallment': false,
            }
          )
        ]
      );

      when(() => mockDatabases.listDocuments(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        queries: any(named: 'queries'),
      )).thenAnswer((_) async => mockDocList);

      final result = await repository.getDebtsLoans('u1');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('addDebtLoan debe llamar a createDocument', () async {
      when(() => mockDatabases.createDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => models.Document(
        $id: '1', 
        $collectionId: 'c', 
        $databaseId: 'd', 
        $createdAt: '', 
        $updatedAt: '', 
        $permissions: [], 
        $sequence: 0,
        data: {}
      ));

      await repository.addDebtLoan(tDebt);

      verify(() => mockDatabases.createDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: '1',
        data: any(named: 'data'),
      )).called(1);
    });
  });
}
