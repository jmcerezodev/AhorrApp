import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/shopping_templates_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingTemplatesCubit extends Mock implements ShoppingTemplatesCubit {}
class MockShoppingListCubit extends Mock implements ShoppingListCubit {}

void main() {
  late MockShoppingTemplatesCubit mockTemplatesCubit;
  late MockShoppingListCubit mockListCubit;

  setUp(() {
    mockTemplatesCubit = MockShoppingTemplatesCubit();
    mockListCubit = MockShoppingListCubit();

    when(() => mockTemplatesCubit.state).thenReturn(const ShoppingTemplatesState());
    when(() => mockTemplatesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTemplatesCubit.loadTemplates()).thenAnswer((_) async => {});
    
    when(() => mockListCubit.state).thenReturn(const ShoppingState());
    when(() => mockListCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockListCubit.addItemsFromTemplate(any())).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ShoppingTemplatesCubit>.value(value: mockTemplatesCubit),
            BlocProvider<ShoppingListCubit>.value(value: mockListCubit),
          ],
          child: const ShoppingTemplatesDialog(),
        ),
      ),
    );
  }

  group('ShoppingTemplatesDialog - Pruebas de Interfaz', () {
    testWidgets('Debe mostrar mensaje de ayuda cuando no hay favoritos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('MIS FAVORITOS'), findsOneWidget);
      expect(find.textContaining('Guarda productos de tu lista'), findsOneWidget);
    });

    testWidgets('Debe mostrar el chip SIN PRECIO si el importe es 0', (WidgetTester tester) async {
      final templates = [
        const ShoppingTemplate(
          id: '1', 
          userId: 'u1', 
          name: 'Agua', 
          items: [ShoppingTemplateItem(name: 'Agua', amount: 0.0)]
        )
      ];
      
      when(() => mockTemplatesCubit.state).thenReturn(ShoppingTemplatesState(templates: templates));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('SIN PRECIO'), findsOneWidget);
    });

    testWidgets('Debe mostrar el importe correcto si el favorito tiene precio', (WidgetTester tester) async {
      final templates = [
        const ShoppingTemplate(
          id: '1', 
          userId: 'u1', 
          name: 'Leche', 
          items: [ShoppingTemplateItem(name: 'Leche', amount: 1.50)]
        )
      ];
      
      when(() => mockTemplatesCubit.state).thenReturn(ShoppingTemplatesState(templates: templates));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('1,50€'), findsOneWidget);
    });

    testWidgets('Debe llamar a addItemsFromTemplate y mostrar SuccessfulDialogNoGo al añadir un producto', (WidgetTester tester) async {
      final templates = [
        const ShoppingTemplate(
          id: '1', 
          userId: 'u1', 
          name: 'Pan', 
          items: [ShoppingTemplateItem(name: 'Pan', amount: 0.85)]
        )
      ];
      
      when(() => mockTemplatesCubit.state).thenReturn(ShoppingTemplatesState(templates: templates));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Buscamos el botón de añadir (es un GestureDetector con un Icon específico)
      final addButton = find.byIcon(Icons.add_circle_outline_rounded).last;
      await tester.tap(addButton);
      await tester.pumpAndSettle(); // Esperamos a que termine la animación del diálogo

      // Verificamos que se llamó al cubit
      verify(() => mockListCubit.addItemsFromTemplate(any())).called(1);

      // Verificamos que aparece el diálogo de éxito con el nuevo título y mensaje
      expect(find.byType(SuccessfulDialogNoGo), findsOneWidget);
      expect(find.text('¡A LA CESTA!'), findsOneWidget);
      expect(find.text('¡Pan añadido correctamente!'), findsOneWidget);
    });
  });
}
