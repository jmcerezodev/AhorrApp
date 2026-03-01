import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/usecases/get_movements_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetMovementsUseCase extends Mock implements GetMovementsUseCase {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HistoryCubit historyCubit;
  late MockGetMovementsUseCase mockGetMovementsUseCase;
  late MockAppwriteRepository mockRepo;
  late MockLocalDbService mockLocalDb;
  late MockTotalMoneyCubit mockTotalMoneyCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockGetMovementsUseCase = MockGetMovementsUseCase();
    mockRepo = MockAppwriteRepository();
    mockLocalDb = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();

    getIt.reset();
    getIt.registerSingleton<GetMovementsUseCase>(mockGetMovementsUseCase);
    getIt.registerSingleton<AppwriteRepository>(mockRepo);
    getIt.registerSingleton<LocalDbService>(mockLocalDb);

    historyCubit = HistoryCubit(totalMoneyCubit: mockTotalMoneyCubit);
  });

  group('HistoryCubit - Blindaje de Lógica', () {
    test('Estado inicial debe ser invalid y lista vacía', () {
      expect(historyCubit.state.formStatus, FormStatusHistory.invalid);
      expect(historyCubit.state.historyList, isEmpty);
    });

    test('toggleFilterPanel debe cambiar el estado del filtro', () {
      expect(historyCubit.state.isFilterOpen, false);
      historyCubit.toggleFilterPanel();
      expect(historyCubit.state.isFilterOpen, true);
    });

    test('loadHistoryByDate debe fallar si no hay datos en Isar ni Appwrite', () async {
      when(() => mockLocalDb.getTotalCount()).thenAnswer((_) async => 0);
      when(() => mockRepo.syncFullData(any(), any())).thenThrow(Exception('No data'));

      await historyCubit.loadHistoryByDate('October', 2023);
      
      expect(historyCubit.state.formStatus, FormStatusHistory.invalid);
    });
  });
}
