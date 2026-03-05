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

    test('loadTemplates debe emitir success con lista de plantillas', () async {
      final templates = [const ShoppingTemplate(id: '1', userId: 'u1', name: 'Pack 1', items: [])];
      when(() => mockGet(any())).thenAnswer((_) async => templates);
      
      await cubit.loadTemplates();
      
      expect(cubit.state.status, ShoppingTemplatesStatus.success);
      expect(cubit.state.templates.length, 1);
    });

    test('saveTemplate debe guardar y recargar la lista', () async {
      when(() => mockSave(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.saveTemplate('Pack Semanal', [
        const ShoppingTemplateItem(name: 'Leche', amount: 1.5)
      ]);
      
      verify(() => mockSave(any())).called(1);
      verify(() => mockGet(any())).called(1);
    });

    test('deleteTemplate debe eliminar y recargar la lista', () async {
      when(() => mockDelete(any())).thenAnswer((_) async {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      
      await cubit.deleteTemplate('123');
      
      verify(() => mockDelete('123')).called(1);
      verify(() => mockGet(any())).called(1);
    });
  });
}
