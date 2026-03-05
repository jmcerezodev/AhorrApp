import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/screens/shopping_list_screen.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingCubit extends Mock implements ShoppingListCubit {}

void main() {
  late MockShoppingCubit mockShoppingCubit;

  setUp(() {
    mockShoppingCubit = MockShoppingCubit();
    
    when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(
      status: ShoppingStatus.success,
      items: [
        ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'alimentación'),
        ShoppingListItem(id: '2', userId: 'u1', name: 'Pan', amount: 0.0, category: 'alimentación'),
      ],
    ));
    when(() => mockShoppingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockShoppingCubit.loadItems()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ShoppingListCubit>.value(
        value: mockShoppingCubit,
        child: const ShoppingListScreen(),
      ),
    );
  }

  group('ShoppingListScreen Widget Tests', () {
    testWidgets('Debe mostrar el título y el icono de sección en el AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('LISTA DE LA COMPRA'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_basket_rounded), findsOneWidget);
    });

    testWidgets('La tarjeta de resumen debe mostrar el botón AÑADIR', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('AÑADIR'), findsOneWidget);
      expect(find.byIcon(Icons.add_shopping_cart_rounded), findsOneWidget);
    });

    testWidgets('Debe mostrar el botón de PRECIO para items sin importe', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // "1,50€" aparece dos veces: en el resumen total y en el item "Leche"
      expect(find.text('1,50€'), findsNWidgets(2));
      expect(find.text('PRECIO'), findsOneWidget);
    });

    testWidgets('La tarjeta de resumen debe ser visible incluso sin items', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificamos que aunque no haya items, la tarjeta de resumen exista
      expect(find.byType(ShoppingSummaryWidget), findsOneWidget);
      expect(find.text('TOTAL ESTIMADO'), findsOneWidget);
      expect(find.text('LISTA VACÍA'), findsOneWidget);
    });
  });
}
