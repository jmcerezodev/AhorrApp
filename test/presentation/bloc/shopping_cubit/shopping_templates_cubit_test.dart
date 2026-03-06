import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_template_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_templates_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_template_usecase.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetShoppingTemplatesUseCase extends Mock implements GetShoppingTemplatesUseCase {}
class MockSaveShoppingTemplateUseCase extends Mock implements SaveShoppingTemplateUseCase {}
class MockDeleteShoppingTemplateUseCase extends Mock implements DeleteShoppingTemplateUseCase {}

void main() {
  late ShoppingTemplatesCubit cubit;
  late MockGetShoppingTemplatesUseCase mockGet;
  late MockSaveShoppingTemplateUseCase mockSave;
  late MockDeleteShoppingTemplateUseCase mockDelete;

  setUpAll(() {
    registerFallbackValue(const ShoppingTemplate(id: '', userId: '', name: '', items: []));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockGet = MockGetShoppingTemplatesUseCase();
    mockSave = MockSaveShoppingTemplateUseCase();
    mockDelete = MockDeleteShoppingTemplateUseCase();

    cubit = ShoppingTemplatesCubit(
      getTemplatesUseCase: mockGet,
      saveTemplateUseCase: mockSave,
      deleteTemplateUseCase: mockDelete,
    );
  });

  group('ShoppingTemplatesCubit Tests', () {
    test('Estado inicial debe ser correcto', () {
      expect(cubit.state, const ShoppingTemplatesState());
    });

    test('loadTemplates debe emitir success con lista de favoritos', () async {
      final templates = [const ShoppingTemplate(id: '1', userId: 'test-user', name: 'Leche', items: [])];
      when(() => mockGet(any())).thenAnswer((_) async => templates);
      
      await cubit.loadTemplates();
      
      expect(cubit.state.status, ShoppingTemplatesStatus.success);
      expect(cubit.state.templates.length, 1);
    });

    test('saveTemplate no debe guardar si el producto ya es favorito', () async {
      final existing = [const ShoppingTemplate(id: '1', userId: 'u1', name: 'Leche', items: [])];
      when(() => mockGet(any())).thenAnswer((_) async => existing);
      await cubit.loadTemplates();

      await cubit.saveTemplate('LECHE', []); // Intento con mayúsculas
      
      verifyNever(() => mockSave(any()));
    });

    test('updateOrSaveFavorite debe guardar correctamente un nuevo favorito', () async {
      when(() => mockSave(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.updateOrSaveFavorite(name: 'Pan', amount: 1.0, category: 'general');
      
      final captured = verify(() => mockSave(captureAny())).captured.first as ShoppingTemplate;
      expect(captured.name, 'Pan');
      expect(captured.items.first.amount, 1.0);
    });

    test('deleteTemplate debe eliminar y recargar', () async {
      when(() => mockDelete(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.deleteTemplate('123');
      
      verify(() => mockDelete('123')).called(1);
      verify(() => mockGet(any())).called(1);
    });
  });

  group('ShoppingTemplatesState Helpers', () {
    test('isFavorite debe detectar nombres duplicados ignoreCase', () {
      const state = ShoppingTemplatesState(templates: [
        ShoppingTemplate(id: '1', userId: 'u1', name: 'Leche', items: [])
      ]);

      expect(state.isFavorite('leche'), isTrue);
      expect(state.isFavorite('LECHE'), isTrue);
      expect(state.isFavorite('Pan'), isFalse);
    });

    test('getFavoriteId debe retornar el ID correcto si existe', () {
      const state = ShoppingTemplatesState(templates: [
        ShoppingTemplate(id: 'fav_id_123', userId: 'u1', name: 'Leche', items: [])
      ]);

      expect(state.getFavoriteId('Leche'), 'fav_id_123');
      expect(state.getFavoriteId('Pan'), isNull);
    });
  });
}
