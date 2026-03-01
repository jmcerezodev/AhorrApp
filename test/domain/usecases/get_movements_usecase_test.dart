import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/usecases/get_movements_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}

void main() {
  late GetMovementsUseCase useCase;
  late MockMovementRepository mockLocalRepo;
  late MockMovementRepository mockRemoteRepo;

  setUp(() {
    mockLocalRepo = MockMovementRepository();
    mockRemoteRepo = MockMovementRepository();
    useCase = GetMovementsUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
    );
  });

  group('GetMovementsUseCase - Lógica de Sincronización', () {
    test('debe retornar datos remotos cuando local está vacío y hay conexión', () async {
      final tMovements = [
        Movement(
          id: '1', name: 'Test', amount: 10, type: MovementType.income, 
          isIncome: true, date: '1/10/2023', hour: '12:00', month: 'October', 
          year: 2023, createdAt: DateTime.now()
        )
      ];

      // Local está vacío
      when(() => mockLocalRepo.getMovementsByMonth(any(), any(), any()))
          .thenAnswer((_) async => []);
      
      // Remoto tiene datos
      when(() => mockRemoteRepo.getMovementsByMonth(any(), any(), any()))
          .thenAnswer((_) async => tMovements);

      final result = await useCase.call('user123', 'October', 2023);

      expect(result, tMovements);
      verify(() => mockLocalRepo.getMovementsByMonth('user123', 'October', 2023)).called(1);
      verify(() => mockRemoteRepo.getMovementsByMonth('user123', 'October', 2023)).called(1);
    });

    test('debe retornar datos locales y NO llamar al remoto si local ya tiene datos', () async {
      final tMovements = [
        Movement(
          id: 'local1', name: 'Test Local', amount: 20, type: MovementType.expense, 
          isIncome: false, date: '1/10/2023', hour: '12:00', month: 'October', 
          year: 2023, createdAt: DateTime.now()
        )
      ];

      when(() => mockLocalRepo.getMovementsByMonth(any(), any(), any()))
          .thenAnswer((_) async => tMovements);

      final result = await useCase.call('user123', 'October', 2023);

      expect(result, tMovements);
      verify(() => mockLocalRepo.getMovementsByMonth('user123', 'October', 2023)).called(1);
      // No debería llamar al remoto si ya hay datos locales (ahorro de datos/batería)
      verifyNever(() => mockRemoteRepo.getMovementsByMonth(any(), any(), any()));
    });
  });
}
