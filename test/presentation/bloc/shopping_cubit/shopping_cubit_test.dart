import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_list_item_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetShoppingListUseCase extends Mock implements GetShoppingListUseCase {}
class MockSaveShoppingListItemUseCase extends Mock implements SaveShoppingListItemUseCase {}
class MockDeleteShoppingListItemUseCase extends Mock implements DeleteShoppingListItemUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockHistoryCubit extends Mock implements HistoryCubit {}

void main() {
  late ShoppingListCubit cubit;
  late MockGetShoppingListUseCase mockGet;
  late MockSaveShoppingListItemUseCase mockSave;
  late MockDeleteShoppingListItemUseCase mockDelete;
  late MockSaveMovementUseCase mockSaveMovement;
  late MockHistoryCubit mockHistoryCubit;

  setUpAll(() {
    registerFallbackValue(const ShoppingListItem(id: '', userId: 'u1', name: '', amount: 0, category: '', position: 0));
    registerFallbackValue(Movement(
      id: '',
      name: '',
      amount: 0,
      type: MovementType.expense,
      isIncome: false,
      date: '',
      hour: '',
      month: '',
      year: 2024,
      createdAt: DateTime.now(),
    ));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockGet = MockGetShoppingListUseCase();
    mockSave = MockSaveShoppingListItemUseCase();
    mockDelete = MockDeleteShoppingListItemUseCase();
    mockSaveMovement = MockSaveMovementUseCase();
    mockHistoryCubit = MockHistoryCubit();

    getIt.reset();
    getIt.registerSingleton<GetShoppingListUseCase>(mockGet);
    getIt.registerSingleton<SaveShoppingListItemUseCase>(mockSave);
    getIt.registerSingleton<DeleteShoppingListItemUseCase>(mockDelete);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovement);

    cubit = ShoppingListCubit();
  });

  group('ShoppingCubit - Gestión de Ítems y Cantidades', () {
    test('Estado inicial debe ser correcto', () {
      expect(cubit.state, const ShoppingState());
    });

    test('loadItems debe emitir success con lista de productos', () async {
      final items = [const ShoppingListItem(id: '1', userId: 'test-user', name: 'Leche', amount: 1.5, quantity: 2, position: 0)];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      
      await cubit.loadItems();
      
      expect(cubit.state.status, ShoppingStatus.success);
      expect(cubit.state.items.first.quantity, 2);
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

    test('addItem debe incluir la cantidad especificada', () async {
      when(() => mockSave(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.addItem('Coca Cola', quantity: 3);
      
      final captured = verify(() => mockSave(captureAny())).captured.first as ShoppingListItem;
      expect(captured.name, 'Coca Cola');
      expect(captured.quantity, 3);
    });

    test('updateItem con cambio de cantidad debe aplicar Debounce (esperar 500ms)', () async {
      final itemInitial = const ShoppingListItem(id: '1', userId: 'u1', name: 'Pan', amount: 1.0, quantity: 1);
      final itemUpdated = itemInitial.copyWith(quantity: 2);
      
      when(() => mockGet(any())).thenAnswer((_) async => [itemInitial]);
      when(() => mockSave(any())).thenAnswer((_) async {});
      
      await cubit.loadItems();
      
      // Act: Actualizamos cantidad
      await cubit.updateItem(itemUpdated);
      
      // Verify: UI se actualiza inmediatamente
      expect(cubit.state.items.first.quantity, 2);
      // Verify: El caso de uso NO se ha llamado aún por el debounce
      verifyNever(() => mockSave(any()));

      // Wait: Esperamos al timer de debounce
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Verify: Ahora sí se ha llamado
      verify(() => mockSave(any())).called(1);
    });
  });

  group('ShoppingCubit - Lógica de Transferencia a Gastos', () {
    test('transferToExpenses debe fallar si hay items comprados sin precio', () async {
      final items = [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Sin Precio', amount: 0.0, isBought: true, position: 0)
      ];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      await cubit.loadItems();

      await cubit.transferToExpenses(asPack: true, historyCubit: mockHistoryCubit);

      expect(cubit.state.status, ShoppingStatus.failure);
      expect(cubit.state.errorMessage, contains('sin precio'));
    });

    test('transferToExpenses asPack debe crear un solo movimiento y limpiar la cesta', () async {
      final items = [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Item 1', amount: 10.0, isBought: true, position: 0),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Item 2', amount: 5.0, isBought: true, position: 1),
      ];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});
      
      await cubit.loadItems();

      await cubit.transferToExpenses(asPack: true, historyCubit: mockHistoryCubit, packName: 'Compra Pack');

      final capturedMovement = verify(() => mockSaveMovement(captureAny())).captured.first as Movement;
      expect(capturedMovement.amount, 15.0);
      expect(capturedMovement.name, 'Compra Pack');
      verify(() => mockDelete(any())).called(2);
      verify(() => mockHistoryCubit.loadHistoryByDate(any(), any())).called(1);
      expect(cubit.state.status, ShoppingStatus.success);
    });

    test('transferToExpenses debe tener en cuenta las cantidades para el total', () async {
      final items = [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, quantity: 2, isBought: true), // 3.0€
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 1.0, quantity: 3, isBought: true),   // 3.0€
      ];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});
      
      await cubit.loadItems();

      await cubit.transferToExpenses(asPack: true, historyCubit: mockHistoryCubit, packName: 'Compra Semanal');

      final capturedMovement = verify(() => mockSaveMovement(captureAny())).captured.first as Movement;
      expect(capturedMovement.amount, 6.0); // (1.5 * 2) + (1.0 * 3)
    });

    test('transferToExpenses individual debe incluir el multiplicador en el nombre del movimiento', () async {
      final items = [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Agua', amount: 0.5, quantity: 6, isBought: true),
      ];
      when(() => mockGet(any())).thenAnswer((_) async => items);
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});
      
      await cubit.loadItems();

      await cubit.transferToExpenses(asPack: false, historyCubit: mockHistoryCubit);

      final capturedMovement = verify(() => mockSaveMovement(captureAny())).captured.first as Movement;
      expect(capturedMovement.name, '6x Agua');
      expect(capturedMovement.amount, 3.0);
    });
  });

  group('ShoppingCubit - Cálculos de Estado con Cantidades', () {
    test('totalPrice debe multiplicar cantidad por importe', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Item 1', amount: 2.0, quantity: 3), // 6.0
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Item 2', amount: 1.5, quantity: 2), // 3.0
      ]);
      expect(state.totalPrice, 9.0);
    });

    test('totalBoughtPrice debe calcular solo los productos en la cesta', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'Lacteos', isBought: false),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 1.0, category: 'Panaderia', isBought: true),
        const ShoppingListItem(id: '3', userId: 'u1', name: 'Huevos', amount: 3.0, category: 'Basicos', isBought: true),
      ]);
      expect(state.totalBoughtPrice, 4.0);
    });

    test('totalBought debe contar los productos marcados como comprados', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'Lacteos', position: 0, isBought: true),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 1, category: 'Panaderia', position: 1),
        const ShoppingListItem(id: '3', userId: 'u1', name: 'Huevos', amount: 3, category: 'Basicos', position: 2, isBought: true),
      ]);
      expect(state.totalBought, 2);
    });

    test('totalPrice con ceros debe ser correcto', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Gratis', amount: 0.0, quantity: 10),
      ]);
      expect(state.totalPrice, 0.0);
    });

    test('totalBought debe sumar las cantidades de los productos comprados', () {
      final state = ShoppingState(items: [
        const ShoppingListItem(id: '1', userId: 'u1', name: 'Comprado', quantity: 5, isBought: true),
        const ShoppingListItem(id: '2', userId: 'u1', name: 'No Comprado', quantity: 10, isBought: false),
        const ShoppingListItem(id: '3', userId: 'u1', name: 'Comprado 2', quantity: 2, isBought: true),
      ]);
      expect(state.totalBought, 7);
    });
  });
}
