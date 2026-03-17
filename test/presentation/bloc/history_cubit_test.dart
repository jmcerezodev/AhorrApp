import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/get_movements_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mock_definitions.dart';

class MockGetMovementsUseCase extends Mock implements GetMovementsUseCase {}

void main() {
  late HistoryCubit historyCubit;
  late MockTotalMoneyCubit mockTotalMoneyCubit;
  late MockGetMovementsUseCase mockGetMovementsUseCase;
  late MockAppwriteRepository mockAppwriteRepository;
  late MockLocalDbService mockLocalDbService;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockTotalMoneyCubit = MockTotalMoneyCubit();
    mockGetMovementsUseCase = MockGetMovementsUseCase();
    mockAppwriteRepository = MockAppwriteRepository();
    mockLocalDbService = MockLocalDbService();
    mockPrefs = MockSharedPreferences();

    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');

    historyCubit = HistoryCubit(
      totalMoneyCubit: mockTotalMoneyCubit,
      getMovementsUseCase: mockGetMovementsUseCase,
      repository: mockAppwriteRepository,
      localDb: mockLocalDbService,
    );
  });

  tearDown(() {
    historyCubit.close();
  });

  group('HistoryCubit - Unit Tests', () {
    final mockMovements = [
      Movement(
        id: '1',
        name: 'Salary',
        amount: 1000.0,
        type: MovementType.income,
        isIncome: true,
        date: '01/01/2024',
        hour: '10:00 AM',
        month: 'Enero',
        year: 2024,
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<HistoryCubit, HistoryCubitState>(
      'loadHistoryByDate should emit [loading, success] with movements',
      build: () => historyCubit,
      setUp: () {
        when(() => mockLocalDbService.getTotalCount()).thenAnswer((_) async => 10);
        when(() => mockLocalDbService.getTotalBalance(any())).thenAnswer((_) async => 500.0);
        when(() => mockGetMovementsUseCase(any(), any(), any()))
            .thenAnswer((_) async => mockMovements);
      },
      act: (cubit) => cubit.loadHistoryByDate('Enero', 2024),
      expect: () => [
        isA<HistoryCubitState>().having((s) => s.status, 'status', HistoryStatus.loading),
        isA<HistoryCubitState>().having((s) => s.status, 'status', HistoryStatus.success)
            .having((s) => s.historyList.length, 'historyList length', 1),
      ],
      verify: (_) {
        verify(() => mockTotalMoneyCubit.totalMoney(500.0)).called(1);
      },
    );

    blocTest<HistoryCubit, HistoryCubitState>(
      'loadHistoryByDate should emit failure when usecase fails',
      build: () => historyCubit,
      setUp: () {
        when(() => mockLocalDbService.getTotalCount()).thenAnswer((_) async => 10);
        when(() => mockLocalDbService.getTotalBalance(any())).thenAnswer((_) async => 500.0);
        when(() => mockGetMovementsUseCase(any(), any(), any()))
            .thenThrow(Exception('DB Error'));
      },
      act: (cubit) => cubit.loadHistoryByDate('Enero', 2024),
      expect: () => [
        isA<HistoryCubitState>().having((s) => s.status, 'status', HistoryStatus.loading),
        isA<HistoryCubitState>().having((s) => s.status, 'status', HistoryStatus.failure),
      ],
    );

    blocTest<HistoryCubit, HistoryCubitState>(
      'forceBalanceResync should clear local DB and sync from Appwrite',
      build: () => historyCubit,
      setUp: () {
        when(() => mockLocalDbService.clearAll()).thenAnswer((_) async => {});
        when(() => mockAppwriteRepository.syncFullData(any(), any()))
            .thenAnswer((_) async => {
                  'history': [],
                  'savings': [],
                  'recurrent': [],
                  'shopping': [],
                  'templates': [],
                  'tickets': [],
                  'debts': [],
                  'savingGoal': 100.0,
                  'balance': 1500.0,
                });
        when(() => mockLocalDbService.saveHistoryItems(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveSavingItems(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveRecurrentExpenses(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveShoppingListItems(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveShoppingTemplates(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveTicketItems(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveDebtLoans(any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveSavingGoal(any(), any())).thenAnswer((_) async => {});
        when(() => mockLocalDbService.saveTotalBalance(any(), any())).thenAnswer((_) async => {});
        when(() => mockGetMovementsUseCase(any(), any(), any())).thenAnswer((_) async => []);
      },
      act: (cubit) => cubit.forceBalanceResync(mockTotalMoneyCubit),
      expect: () => [
        isA<HistoryCubitState>()
            .having((s) => s.status, 'status', HistoryStatus.loading)
            .having((s) => s.isSyncing, 'isSyncing', true),
        isA<HistoryCubitState>()
            .having((s) => s.status, 'status', HistoryStatus.success)
            .having((s) => s.isSyncing, 'isSyncing', false)
            .having((s) => s.syncProgress, 'syncProgress', 1.0),
      ],
      verify: (_) {
        verify(() => mockLocalDbService.clearAll()).called(1);
        verify(() => mockTotalMoneyCubit.totalMoney(1500.0)).called(1);
      },
    );

    group('HistoryCubit - Filtering', () {
      blocTest<HistoryCubit, HistoryCubitState>(
        'toggleCategoryFilter should update selectedCategories list',
        build: () => historyCubit,
        act: (cubit) {
          cubit.toggleCategoryFilter('Alimentación');
          cubit.toggleCategoryFilter('Transporte');
          cubit.toggleCategoryFilter('Alimentación'); // should remove it
        },
        expect: () => [
          isA<HistoryCubitState>().having((s) => s.selectedCategories, 'categories', ['Alimentación']),
          isA<HistoryCubitState>().having((s) => s.selectedCategories, 'categories', ['Alimentación', 'Transporte']),
          isA<HistoryCubitState>().having((s) => s.selectedCategories, 'categories', ['Transporte']),
        ],
      );
    });

   group('HistoryCubit - Preparation', () {
      blocTest<HistoryCubit, HistoryCubitState>(
        'prepareForNewLogin should clear DB and reset state',
        build: () => historyCubit,
        setUp: () {
          when(() => mockLocalDbService.clearAll()).thenAnswer((_) async => {});
        },
        act: (cubit) => cubit.prepareForNewLogin(),
        expect: () => [
          const HistoryCubitState(),
        ],
        verify: (_) {
          verify(() => mockLocalDbService.clearAll()).called(1);
        },
      );
    });
  });
}
