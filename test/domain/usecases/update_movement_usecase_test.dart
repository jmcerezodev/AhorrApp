import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/usecases/update_movement_usecase.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}

// Fake para que mocktail acepte objetos Movement
class FakeMovement extends Fake implements Movement {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late UpdateMovementUseCase useCase;
  late MockMovementRepository mockLocalRepo;
  late MockAppwriteRepository mockRemoteDataSource;
  late MockLocalDbService mockLocalDbService;
  late MockTotalMoneyCubit mockTotalMoneyCubit;

  setUpAll(() {
    registerFallbackValue(FakeMovement());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockLocalRepo = MockMovementRepository();
    mockRemoteDataSource = MockAppwriteRepository();
    mockLocalDbService = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    
    useCase = UpdateMovementUseCase(
      localRepository: mockLocalRepo,
      remoteDataSource: mockRemoteDataSource,
      localDbService: mockLocalDbService,
      totalMoneyCubit: mockTotalMoneyCubit,
    );
  });

  final tMovement = Movement(
    id: '123',
    name: 'Updated Movement',
    amount: 150.0,
    type: MovementType.income,
    isIncome: true,
    date: '2023-10-27',
    hour: '12:00',
    month: 'October',
    year: 2023,
    createdAt: DateTime.now(),
  );

  test('debe actualizar en local y encolar si falla el remoto (Offline)', () async {
    // Arrange
    when(() => mockLocalRepo.saveMovement(any())).thenAnswer((_) async => {});
    when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 100.0);
    when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
    
    // Simulamos fallo de red en la actualización
    when(() => mockRemoteDataSource.updateHistory(documentId: any(named: 'documentId'), data: any(named: 'data')))
        .thenThrow(Exception('No internet'));
    
    when(() => mockLocalDbService.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
        .thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement, 100.0); // oldAmount = 100.0

    // Assert
    verify(() => mockLocalRepo.saveMovement(tMovement)).called(1);
    // Verifica que se intentó actualizar en remoto (Appwrite)
    verify(() => mockRemoteDataSource.updateHistory(documentId: '123', data: {'name': 'Updated Movement', 'money': 150.0})).called(1);
    // Verifica que se añadió a la cola de sincronización
    verify(() => mockLocalDbService.addPendingSync(
      'update',
      'history',
      {'name': 'Updated Movement', 'money': 150.0},
      appwriteId: '123'
    )).called(1);
  });
}
