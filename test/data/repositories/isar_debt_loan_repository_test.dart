import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/repositories/isar_debt_loan_repository.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart' as isar;
import 'package:mocktail/mocktail.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockIsar extends Mock implements isar.Isar {}

void main() {
  late IsarDebtLoanRepository repository;
  late MockLocalDbService mockLocalDb;
  late MockIsar mockIsar;

  setUpAll(() {
    registerFallbackValue(() async {});
  });

  setUp(() {
    mockLocalDb = MockLocalDbService();
    mockIsar = MockIsar();
    
    when(() => mockLocalDb.isar).thenReturn(mockIsar);
    repository = IsarDebtLoanRepository(mockLocalDb);
  });

  group('IsarDebtLoanRepository Test -', () {
    test('getDebtsLoans debe retornar lista vacía si localDbService no tiene datos', () async {
      when(() => mockLocalDb.getDebtLoans(any())).thenAnswer((_) async => []);
      
      final result = await repository.getDebtsLoans('user123');
      
      expect(result, isEmpty);
      verify(() => mockLocalDb.getDebtLoans('user123')).called(1);
    });

    test('addDebtLoan debe ejecutar transacción writeTxn', () async {
      final tDebt = DebtLoan(id: '1', userId: 'u1', name: 'N', person: 'P', totalAmount: 10, type: DebtLoanType.debt);
      
      when(() => mockIsar.writeTxn<Null>(any())).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as Future<Null> Function();
        return await callback();
      });
      
      try {
        await repository.addDebtLoan(tDebt);
      } catch (e) {
        // Ignoramos errores de extensiones de Isar sobre mocks
      }
      
      verify(() => mockIsar.writeTxn<Null>(any())).called(1);
    });
  });
}
