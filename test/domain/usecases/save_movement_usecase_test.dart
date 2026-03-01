import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}

// Fake para que mocktail acepte objetos Movement
class FakeMovement extends Fake implements Movement {}

void main() {
  late SaveMovementUseCase useCase;
  late MockMovementRepository mockLocalRepo;
  late MockMovementRepository mockRemoteRepo;
  late MockLocalDbService mockLocalDbService;

  setUpAll(() {
    registerFallbackValue(FakeMovement());
  });

  setUp(() {
    mockLocalRepo = MockMovementRepository();
    mockRemoteRepo = MockMovementRepository();
    mockLocalDbService = MockLocalDbService();
    
    useCase = SaveMovementUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
      localDbService: mockLocalDbService,
    );
  });

  final tMovement = Movement(
    id: '123',
    name: 'Test Movement',
    amount: 100.0,
    type: MovementType.income,
    isIncome: true,
    date: '2023-10-27',
    hour: '12:00',
    month: 'October',
    year: 2023,
    createdAt: DateTime.now(),
  );

  test('debe guardar en local y remoto cuando hay conexión', () async {
    // Arrange
    when(() => mockLocalRepo.saveMovement(any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.saveMovement(any())).thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement);

    // Assert
    verify(() => mockLocalRepo.saveMovement(tMovement)).called(1);
    verify(() => mockRemoteRepo.saveMovement(tMovement)).called(1);
    verifyNever(() => mockLocalDbService.addPendingSync(any(), any(), any()));
  });

  test('debe guardar en local y encolar en pendientes cuando falla el remoto', () async {
    // Arrange
    when(() => mockLocalRepo.saveMovement(any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.saveMovement(any())).thenThrow(Exception('No internet'));
    when(() => mockLocalDbService.addPendingSync(any(), any(), any())).thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement);

    // Assert
    verify(() => mockLocalRepo.saveMovement(tMovement)).called(1);
    verify(() => mockLocalDbService.addPendingSync(
      'create',
      'history',
      any(),
    )).called(1);
  });
}
