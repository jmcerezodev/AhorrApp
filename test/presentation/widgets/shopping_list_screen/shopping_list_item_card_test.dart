import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShoppingListCubit extends Mock implements ShoppingListCubit {}
class MockShoppingTemplatesCubit extends Mock implements ShoppingTemplatesCubit {}

void main() {
  late MockShoppingListCubit mockShoppingCubit;
  late MockShoppingTemplatesCubit mockTemplatesCubit;
  final humanizeNumbers = HumanizeNumbers();

  setUp(() {
    mockShoppingCubit = MockShoppingListCubit();
    mockTemplatesCubit = MockShoppingTemplatesCubit();

    when(() => mockTemplatesCubit.state).thenReturn(const ShoppingTemplatesState());
    when(() => mockTemplatesCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest(ShoppingListItem item) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ShoppingListCubit>.value(value: mockShoppingCubit),
            BlocProvider<ShoppingTemplatesCubit>.value(value: mockTemplatesCubit),
          ],
          child: ShoppingItemCard(
            item: item,
            humanizeNumbers: humanizeNumbers,
            colorScheme: const ColorScheme.light(),
            isDark: false,
          ),
        ),
      ),
    );
  }

  group('ShoppingItemCard Design Tests', () {
    testWidgets('Si NO tiene precio: muestra botón PRECIO y oculta cantidad/stepper', (tester) async {
      const item = ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 0.0, quantity: 1);

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.text('PRECIO'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // Icono dentro del botón precio
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget); // Favorito
      
      // No debe haber badge de cantidad x1
      expect(find.text('x1'), findsNothing);
      // No debe haber botones del stepper (+/-)
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
    });

    testWidgets('Si TIENE precio y cantidad 1: muestra precio y oculta precio/ud', (tester) async {
      const item = ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, quantity: 1);

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.text('1,50€'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget); // Ahora es del stepper
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget); // Stepper
      
      // No debe mostrar precio unitario si la cantidad es 1
      expect(find.textContaining('€/ud'), findsNothing);
    });

    testWidgets('Si TIENE precio y cantidad > 1: muestra precio total y unitario', (tester) async {
      const item = ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, quantity: 2);

      await tester.pumpWidget(createWidgetUnderTest(item));

      expect(find.text('3€'), findsOneWidget); // Total (HumanizeNumbers quita decimales si son .00)
      expect(find.text('1,50€/ud'), findsOneWidget); // Unitario
      expect(find.text('x2'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });
  });
}
