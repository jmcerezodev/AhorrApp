import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mock_definitions.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}

void main() {
  late SaveMovementUseCase saveMovementUseCase;
  late MockMovementRepository mockLocalRepo;
  late MockMovementRepository mockRemoteRepo;
  late MockLocalDbService mockLocalDb;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockLocalRepo = MockMovementRepository();
    mockRemoteRepo = MockMovementRepository();
    mockLocalDb = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockPrefs = MockSharedPreferences();

    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');

    saveMovementUseCase = SaveMovementUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
      localDbService: mockLocalDb,
      totalMoneyCubit: mockTotalMoneyCubit,
    );
    
    // Register fallbacks
    registerFallbackValue(Movement(
      id: '1', name: 'Test', amount: 0, type: MovementType.expense, isIncome: false, 
      date: '', hour: '', month: '', year: 0, createdAt: DateTime.now()
    ));
  });

  group('Offline Resilience - SaveMovementUseCase', () {
    final testMovement = Movement(
      id: 'move-123',
      name: 'Dinner',
      amount: 50.0,
      type: MovementType.expense,
      isIncome: false,
      date: '20/05/2024',
      hour: '09:00 PM',
      month: 'Mayo',
      year: 2024,
      createdAt: DateTime.now(),
    );

    test('should save locally and add to PendingSync when remote fails (Offline)', () async {
      // 1. Setup mocks
      when(() => mockLocalRepo.saveMovement(any())).thenAnswer((_) async => {});
      when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 1000.0);
      when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
      
      // Simular fallo de red
      when(() => mockRemoteRepo.saveMovement(any())).thenThrow(Exception('No connection'));
      when(() => mockRemoteRepo.updateGlobalBalance(any(), any())).thenThrow(Exception('No connection'));
      
      // Mock pending sync storage
      when(() => mockLocalDb.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
          .thenAnswer((_) async => 1);

      // 2. Act
      await saveMovementUseCase.call(testMovement);

      // 3. Assert
      verify(() => mockLocalRepo.saveMovement(any())).called(1);
      verify(() => mockLocalRepo.updateGlobalBalance('user-123', 950.0)).called(1);
      
      // Verificamos que se ha creado la entrada en la cola de sincronización pendiente
      verify(() => mockLocalDb.addPendingSync(
            'create',
            'history',
            any(that: isA<Map<String, dynamic>>()),
            appwriteId: 'move-123',
          )).called(1);
    });

    test('should update local balance even if remote balance update fails', () async {
      when(() => mockLocalRepo.saveMovement(any())).thenAnswer((_) async => {});
      when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 1000.0);
      when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
      when(() => mockRemoteRepo.updateGlobalBalance(any(), any())).thenThrow(Exception('Network Error'));
      when(() => mockRemoteRepo.saveMovement(any())).thenAnswer((_) async => {});
      when(() => mockLocalDb.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
          .thenAnswer((_) async => 1);

      await saveMovementUseCase.call(testMovement);

      verify(() => mockLocalRepo.updateGlobalBalance('user-123', 950.0)).called(1);
      verify(() => mockTotalMoneyCubit.totalMoney(950.0)).called(1);
    });
  });
}
