import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/shopping_item.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_item_usecase.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetShoppingListUseCase extends Mock implements GetShoppingListUseCase {}
class MockSaveShoppingItemUseCase extends Mock implements SaveShoppingItemUseCase {}
class MockDeleteShoppingItemUseCase extends Mock implements DeleteShoppingItemUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ShoppingCubit cubit;
  late MockGetShoppingListUseCase mockGet;
  late MockSaveShoppingItemUseCase mockSave;
  late MockDeleteShoppingItemUseCase mockDelete;

  setUpAll(() {
    registerFallbackValue(const ShoppingItem(
      id: '',
      userId: '',
      name: '',
    ));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'user123'});
    await Preferences.init();

    mockGet = MockGetShoppingListUseCase();
    mockSave = MockSaveShoppingItemUseCase();
    mockDelete = MockDeleteShoppingItemUseCase();

    getIt.reset();
    getIt.registerSingleton<GetShoppingListUseCase>(mockGet);
    getIt.registerSingleton<SaveShoppingItemUseCase>(mockSave);
    getIt.registerSingleton<DeleteShoppingItemUseCase>(mockDelete);

    cubit = ShoppingCubit();
  });

  group('ShoppingCubit Tests', () {
    test('Estado inicial debe ser correcto', () {
      expect(cubit.state.status, ShoppingStatus.initial);
      expect(cubit.state.items, isEmpty);
    });

    test('loadItems debe emitir success con lista de productos', () async {
      final items = [
        const ShoppingItem(id: '1', userId: 'user123', name: 'Leche', amount: 1.5, category: 'alimentación'),
      ];
      when(() => mockGet(any())).thenAnswer((_) async => items);

      await cubit.loadItems();

      expect(cubit.state.status, ShoppingStatus.success);
      expect(cubit.state.items, items);
    });

    test('addItem debe guardar y recargar la lista', () async {
      when(() => mockSave(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.addItem('Pan', amount: 0.5, category: 'alimentación');

      verify(() => mockSave(any())).called(1);
      verify(() => mockGet('user123')).called(1);
    });

    test('toggleItem debe invertir isBought y guardar', () async {
      final item = const ShoppingItem(id: '1', userId: 'user123', name: 'Leche', isBought: false);
      when(() => mockSave(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.toggleItem(item);

      final captured = verify(() => mockSave(captureAny())).captured.first as ShoppingItem;
      expect(captured.isBought, true);
    });

    test('deleteItem debe eliminar y recargar', () async {
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.deleteItem('1');

      verify(() => mockDelete('1')).called(1);
      verify(() => mockGet('user123')).called(1);
    });

    test('totalPrice debe calcular la suma de los importes correctamente', () {
      final items = [
        const ShoppingItem(id: '1', userId: 'u1', name: 'A', amount: 10.0),
        const ShoppingItem(id: '2', userId: 'u1', name: 'B', amount: 5.5),
      ];
      final state = ShoppingState(items: items);
      expect(state.totalPrice, 15.5);
    });

    test('totalBought debe contar los productos marcados como comprados', () {
      final items = [
        const ShoppingItem(id: '1', userId: 'u1', name: 'A', isBought: true),
        const ShoppingItem(id: '2', userId: 'u1', name: 'B', isBought: false),
        const ShoppingItem(id: '3', userId: 'u1', name: 'C', isBought: true),
      ];
      final state = ShoppingState(items: items);
      expect(state.totalBought, 2);
    });
  });
}
