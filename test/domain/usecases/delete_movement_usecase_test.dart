import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/domain/usecases/delete_movement_usecase.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockMovementRepository extends Mock implements IMovementRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}
class MockTicketsRepository extends Mock implements TicketsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DeleteMovementUseCase useCase;
  late MockMovementRepository mockLocalRepo;
  late MockMovementRepository mockRemoteRepo;
  late MockLocalDbService mockLocalDbService;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockTicketsRepository mockTicketsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockLocalRepo = MockMovementRepository();
    mockRemoteRepo = MockMovementRepository();
    mockLocalDbService = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockTicketsRepo = MockTicketsRepository();
    
    useCase = DeleteMovementUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
      localDbService: mockLocalDbService,
      totalMoneyCubit: mockTotalMoneyCubit,
      ticketsRepository: mockTicketsRepo,
    );
  });

  final tMovement = Movement(
    id: '123',
    name: 'Test Movement',
    amount: 100.0,
    type: MovementType.expense,
    isIncome: false,
    date: '2023-10-27',
    hour: '12:00',
    month: 'October',
    year: 2023,
    createdAt: DateTime.now(),
    ticketId: 'ticket_001',
  );

  test('debe eliminar en local y desmarcar el ticket como transferido si tiene ticketId', () async {
    // Arrange
    when(() => mockLocalRepo.deleteMovement(any())).thenAnswer((_) async => {});
    when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 500.0);
    when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.deleteMovement(any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
    when(() => mockTicketsRepo.unmarkAsTransferred(any())).thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement);

    // Assert
    verify(() => mockLocalRepo.deleteMovement('123')).called(1);
    verify(() => mockTicketsRepo.unmarkAsTransferred('ticket_001')).called(1);
  });

  test('debe eliminar en local y encolar si falla el remoto (Offline)', () async {
    // Arrange
    when(() => mockLocalRepo.deleteMovement(any())).thenAnswer((_) async => {});
    when(() => mockLocalRepo.getGlobalBalance(any())).thenAnswer((_) async => 500.0);
    when(() => mockLocalRepo.updateGlobalBalance(any(), any())).thenAnswer((_) async => {});
    when(() => mockTicketsRepo.unmarkAsTransferred(any())).thenAnswer((_) async => {});
    
    // Simulamos fallo de red
    when(() => mockRemoteRepo.deleteMovement(any())).thenThrow(Exception('No internet'));
    
    // Stub para la cola de sincronización
    when(() => mockLocalDbService.addPendingSync(any(), any(), any(), appwriteId: any(named: 'appwriteId')))
        .thenAnswer((_) async => {});

    // Act
    await useCase.call(tMovement);

    // Assert
    verify(() => mockLocalRepo.deleteMovement('123')).called(1);
    verify(() => mockRemoteRepo.deleteMovement('123')).called(1);
    verify(() => mockLocalDbService.addPendingSync(
      'delete',
      'history',
      {},
      appwriteId: '123'
    )).called(1);
  });
}
