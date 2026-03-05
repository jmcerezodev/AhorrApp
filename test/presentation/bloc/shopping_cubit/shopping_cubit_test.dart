import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_list_item_usecase.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetShoppingListUseCase extends Mock implements GetShoppingListUseCase {}
class MockSaveShoppingListItemUseCase extends Mock implements SaveShoppingListItemUseCase {}
class MockDeleteShoppingListItemUseCase extends Mock implements DeleteShoppingListItemUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

void main() {
  late ShoppingListCubit cubit;
  late MockGetShoppingListUseCase mockGet;
  late MockSaveShoppingListItemUseCase mockSave;
  late MockDeleteShoppingListItemUseCase mockDelete;
  late MockSaveMovementUseCase mockSaveMovement;

  setUpAll(() {
    registerFallbackValue(const ShoppingListItem(id: '', userId: 'u1', name: '', amount: 0, category: '', position: 0));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockGet = MockGetShoppingListUseCase();
    mockSave = MockSaveShoppingListItemUseCase();
    mockDelete = MockDeleteShoppingListItemUseCase();
    mockSaveMovement = MockSaveMovementUseCase();

    getIt.reset();
    getIt.registerSingleton<GetShoppingListUseCase>(mockGet);
    getIt.registerSingleton<SaveShoppingListItemUseCase>(mockSave);
    getIt.registerSingleton<DeleteShoppingListItemUseCase>(mockDelete);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovement);

    cubit = ShoppingListCubit();
  });

  group('ShoppingCubit Tests', () {
    test('Estado inicial debe ser correcto', () {
      expect(cubit.state, const ShoppingState());
    });

    test('loadItems debe emitir success con lista de productos', () async {
      final items = [const ShoppingListItem(id: '1', userId: 'test-user', name: 'Leche', amount: 1.5, category: 'Lacteos', position: 0)];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      
      await cubit.loadItems();
      
      expect(cubit.state.status, ShoppingStatus.success);
      expect(cubit.state.items.length, 1);
    });

    test('addItem debe guardar y recargar la lista', () async {
      when(() => mockSave(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.addItem('Pan');
      
      verify(() => mockSave(any())).called(1);
      verify(() => mockGet(any())).called(1);
    });

    test('toggleItem debe invertir isBought y guardar', () async {
      final item = const ShoppingListItem(id: '1', userId: 'test-user', name: 'Leche', amount: 1.5, category: 'Lacteos', position: 0);
      when(() => mockSave(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.toggleItem(item);
      
      final captured = verify(() => mockSave(captureAny())).captured.first as ShoppingListItem;
      expect(captured.isBought, true);
    });

    test('deleteItem debe eliminar y recargar', () async {
      when(() => mockDelete(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.deleteItem('1');
      
      verify(() => mockDelete('1')).called(1);
      verify(() => mockGet(any())).called(1);
    });
  });

  group('ShoppingCubit - Cálculos de Estado', () {
    test('totalPrice debe calcular la suma de los importes correctamente', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'Lacteos', position: 0),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 1, category: 'Panaderia', position: 1),
        const ShoppingListItem(id: '3', userId: 'u1', name: 'Huevos', amount: 3, category: 'Basicos', position: 2, isBought: true),
      ]);
      expect(state.totalPrice, 5.5);
    });

    test('totalBought debe contar los productos marcados como comprados', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'Lacteos', position: 0, isBought: true),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 1, category: 'Panaderia', position: 1),
        const ShoppingListItem(id: '3', userId: 'u1', name: 'Huevos', amount: 3, category: 'Basicos', position: 2, isBought: true),
      ]);
      expect(state.totalBought, 2);
    });
  });
}
