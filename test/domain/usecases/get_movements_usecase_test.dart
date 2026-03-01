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

  group('GetMovementsUseCase - Lógica de Fuente Única (Isar)', () {
    test('debe retornar lista vacía desde local si no hay movimientos', () async {
      // Arrange: Simulamos que Isar no tiene nada
      when(() => mockLocalRepo.getMovementsByMonth(any(), any(), any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase.call('user123', 'October', 2023);

      // Assert
      expect(result, isEmpty);
      verify(() => mockLocalRepo.getMovementsByMonth('user123', 'October', 2023)).called(1);
      
      // REGLA DE ORO: No debe llamar al remoto para mostrar la UI
      // La sincronización se gestiona por otros procesos para mayor velocidad.
      verifyNever(() => mockRemoteRepo.getMovementsByMonth(any(), any(), any()));
    });

    test('debe retornar datos locales cuando existen', () async {
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
      verifyNever(() => mockRemoteRepo.getMovementsByMonth(any(), any(), any()));
    });
  });
}
