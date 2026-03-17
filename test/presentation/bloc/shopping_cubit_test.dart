import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_list_item_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import '../../mocks/mock_definitions.dart';

class MockGetShoppingListUseCase extends Mock implements GetShoppingListUseCase {}
class MockSaveShoppingListItemUseCase extends Mock implements SaveShoppingListItemUseCase {}
class MockDeleteShoppingListItemUseCase extends Mock implements DeleteShoppingListItemUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockHistoryCubit extends Mock implements HistoryCubit {}

class ShoppingListItemFake extends Fake implements ShoppingListItem {}
class MovementFake extends Fake implements Movement {}

void main() {
  late ShoppingListCubit cubit;
  late MockGetShoppingListUseCase mockGetUseCase;
  late MockSaveShoppingListItemUseCase mockSaveUseCase;
  late MockDeleteShoppingListItemUseCase mockDeleteUseCase;
  late MockSaveMovementUseCase mockSaveMovementUseCase;
  late MockHistoryCubit mockHistoryCubit;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(ShoppingListItemFake());
    registerFallbackValue(MovementFake());
  });

  setUp(() {
    final getIt = GetIt.instance;
    getIt.reset();

    mockGetUseCase = MockGetShoppingListUseCase();
    mockSaveUseCase = MockSaveShoppingListItemUseCase();
    mockDeleteUseCase = MockDeleteShoppingListItemUseCase();
    mockSaveMovementUseCase = MockSaveMovementUseCase();
    mockHistoryCubit = MockHistoryCubit();
    mockPrefs = MockSharedPreferences();

    getIt.registerSingleton<GetShoppingListUseCase>(mockGetUseCase);
    getIt.registerSingleton<SaveShoppingListItemUseCase>(mockSaveUseCase);
    getIt.registerSingleton<DeleteShoppingListItemUseCase>(mockDeleteUseCase);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovementUseCase);

    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');

    cubit = ShoppingListCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('ShoppingListCubit - Unit Tests', () {
    final tItem = ShoppingListItem(
      id: '1',
      userId: 'user-123',
      name: 'Milk',
      amount: 1.5,
      quantity: 2,
    );

    blocTest<ShoppingListCubit, ShoppingState>(
      'loadItems should emit [loading, success] with items',
      build: () => cubit,
      setUp: () {
        when(() => mockGetUseCase(any())).thenAnswer((_) async => [tItem]);
      },
      act: (cubit) => cubit.loadItems(),
      expect: () => [
        isA<ShoppingState>().having((s) => s.status, 'status', ShoppingStatus.loading),
        isA<ShoppingState>()
            .having((s) => s.status, 'status', ShoppingStatus.success)
            .having((s) => s.items, 'items', [tItem]),
      ],
    );

    test('totalPrice should calculate correctly (amount * quantity)', () {
      final item2 = tItem.copyWith(id: '2', amount: 10.0, quantity: 1);
      final state = ShoppingState(items: [tItem, item2]);
      // (1.5 * 2) + (10 * 1) = 3 + 10 = 13.0
      expect(state.totalPrice, 13.0);
    });

    blocTest<ShoppingListCubit, ShoppingState>(
      'transferToExpenses (Pack) should create one movement and clear bought items',
      build: () => cubit,
      seed: () => ShoppingState(items: [tItem.copyWith(isBought: true)]),
      setUp: () {
        when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
        when(() => mockDeleteUseCase(any())).thenAnswer((_) async => {});
        when(() => mockGetUseCase(any())).thenAnswer((_) async => []);
        when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});
      },
      act: (cubit) => cubit.transferToExpenses(
        asPack: true, 
        historyCubit: mockHistoryCubit,
        packName: 'Mercadona'
      ),
      expect: () => [
        isA<ShoppingState>().having((s) => s.status, 'status', ShoppingStatus.loading),
        isA<ShoppingState>().having((s) => s.status, 'status', ShoppingStatus.success),
      ],
      verify: (_) {
        final captured = verify(() => mockSaveMovementUseCase.call(captureAny())).captured.last as Movement;
        expect(captured.name, 'Mercadona');
        expect(captured.amount, 3.0); // 1.5 * 2
        verify(() => mockDeleteUseCase('1')).called(1);
      },
    );

    blocTest<ShoppingListCubit, ShoppingState>(
      'transferToExpenses should fail if some bought items have 0 price',
      build: () => cubit,
      seed: () => ShoppingState(items: [tItem.copyWith(isBought: true, amount: 0.0)]),
      act: (cubit) => cubit.transferToExpenses(
        asPack: true, 
        historyCubit: mockHistoryCubit,
      ),
      expect: () => [
        isA<ShoppingState>()
            .having((s) => s.status, 'status', ShoppingStatus.failure)
            .having((s) => s.errorMessage, 'error', contains('sin precio')),
      ],
    );
  });
}
