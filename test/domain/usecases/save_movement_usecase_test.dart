import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}

// Fake para que mocktail acepte objetos Movement
class FakeMovement extends Fake implements Movement {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SaveMovementUseCase useCase;
  late MockMovementRepository mockLocalRepo;
  late MockMovementRepository mockRemoteRepo;
  late MockLocalDbService mockLocalDbService;
  late MockTotalMoneyCubit mockTotalMoneyCubit;

  setUpAll(() {
    registerFallbackValue(FakeMovement());
  });

  setUp(() async {
    // CORREGIDO: Inicializar preferencias para evitar LateInitializationError
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockLocalRepo = MockMovementRepository();
    mockRemoteRepo = MockMovementRepository();
    mockLocalDbService = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    
    useCase = SaveMovementUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
      localDbService: mockLocalDbService,
      totalMoneyCubit: mockTotalMoneyCubit,
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
    when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 0.0);
    when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement);

    // Assert
    verify(() => mockLocalRepo.saveMovement(tMovement)).called(1);
    verify(() => mockRemoteRepo.saveMovement(tMovement)).called(1);
  });
}
