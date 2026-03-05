import 'package:ahorrapp/domain/entities/shopping_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_cubit.dart';
import 'package:ahorrapp/presentation/screens/shopping_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingCubit extends Mock implements ShoppingCubit {}

void main() {
  late MockShoppingCubit mockShoppingCubit;

  setUp(() {
    mockShoppingCubit = MockShoppingCubit();
    
    when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(
      status: ShoppingStatus.success,
      items: [
        ShoppingItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'alimentación'),
        ShoppingItem(id: '2', userId: 'u1', name: 'Pan', amount: 0.0, category: 'alimentación'),
      ],
    ));
    when(() => mockShoppingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockShoppingCubit.loadItems()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ShoppingCubit>.value(
        value: mockShoppingCubit,
        child: const ShoppingScreen(),
      ),
    );
  }

  group('ShoppingScreen Widget Tests', () {
    testWidgets('Debe mostrar el título y los elementos de la lista', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('LISTA DE LA COMPRA'), findsOneWidget);
      expect(find.text('Leche'), findsOneWidget);
      expect(find.text('Pan'), findsOneWidget);
    });

    testWidgets('Debe mostrar el botón de PRECIO para items sin importe', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // "Leche" tiene precio (1.5), "Pan" no tiene (0.0)
      // "1,50€" aparece dos veces: en el resumen total y en el item "Leche"
      expect(find.text('1,50€'), findsNWidgets(2));
      expect(find.text('PRECIO'), findsOneWidget);
    });

    testWidgets('Debe mostrar la tarjeta de resumen con el total', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('TOTAL ESTIMADO'), findsOneWidget);
      expect(find.text('1,50€'), findsNWidgets(2)); // Uno en el resumen, otro en el item
    });

    testWidgets('Debe mostrar estado vacío si no hay items', (WidgetTester tester) async {
      when(() => mockShoppingCubit.state).thenReturn(const ShoppingState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('LISTA VACÍA'), findsOneWidget);
    });
  });
}
