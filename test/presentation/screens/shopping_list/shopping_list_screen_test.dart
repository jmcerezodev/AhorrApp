import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/screens/shopping_list_screen.dart';
import 'package:ahorrapp/presentation/widgets/shared/empty_list_widget.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_summary_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockShoppingCubit extends Mock implements ShoppingListCubit {}
class MockShoppingTemplatesCubit extends Mock implements ShoppingTemplatesCubit {}

void main() {
  late MockShoppingCubit mockShoppingCubit;
  late MockShoppingTemplatesCubit mockTemplatesCubit;
  late MockThemeCubit mockThemeCubit;

  setUp(() {
    mockShoppingCubit = MockShoppingCubit();
    mockTemplatesCubit = MockShoppingTemplatesCubit();
    mockThemeCubit = MockThemeCubit();
    
    // Garantizar estados iniciales no nulos
    when(() => mockShoppingCubit.state).thenReturn(const ShoppingState());
    when(() => mockShoppingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockShoppingCubit.loadItems()).thenAnswer((_) async => {});

    when(() => mockTemplatesCubit.state).thenReturn(const ShoppingTemplatesState());
    when(() => mockTemplatesCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTemplatesCubit.loadTemplates()).thenAnswer((_) async => {});

    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ShoppingListCubit>.value(value: mockShoppingCubit),
            BlocProvider<ShoppingTemplatesCubit>.value(value: mockTemplatesCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const ShoppingListScreen(),
        ),
      ),
    );
  }

  group('ShoppingListScreen Widget Tests', () {
    testWidgets('Debe mostrar el título y el subtítulo en el AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('LISTA DE LA COMPRA'), findsOneWidget);
      expect(find.text('Tus ahorros empiezan aquí.'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe utilizar animaciones de entrada (FadeInDown)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(FadeInDown), findsWidgets);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('La tarjeta de resumen debe mostrar el botón AÑADIR', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('AÑADIR'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar el botón de PRECIO para items sin importe', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(
        items: [ShoppingListItem(id: '1', userId: 'u1', name: 'Pan', amount: 0.0, category: 'alimentación')]
      ));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('PRECIO'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('La tarjeta de resumen debe ser visible incluso sin items y con el texto correcto', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(ShoppingSummaryWidget), findsOneWidget);
      expect(find.text('TOTAL EN LA CESTA'), findsOneWidget);
      expect(find.text('EN LA CESTA'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar EmptyListWidget cuando la lista está vacía', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyListWidget), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar el botón de MIS FAVORITOS', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('MIS FAVORITOS'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar el botón de transferencia desactivado si no hay items en la cesta', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(
        items: [ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, isBought: false)]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final buttonText = find.text('AÑADIR A GASTOS');
      expect(buttonText, findsOneWidget);
      
      final button = find.ancestor(of: buttonText, matching: find.byType(ElevatedButton));
      final ElevatedButton btnWidget = tester.widget(button);
      expect(btnWidget.enabled, isFalse);
      
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Debe mostrar el botón de transferencia activado si hay items en la cesta', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(
        items: [ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, isBought: true, position: 0)]
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final buttonText = find.text('AÑADIR A GASTOS');
      expect(buttonText, findsOneWidget);
      
      final button = find.ancestor(of: buttonText, matching: find.byType(ElevatedButton));
      final ElevatedButton btnWidget = tester.widget(button);
      expect(btnWidget.enabled, isTrue);
      
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
