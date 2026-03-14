import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/widgets/shopping_list_screen/shopping_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';

class MockShoppingListCubit extends Mock implements ShoppingListCubit {}
class MockShoppingTemplatesCubit extends Mock implements ShoppingTemplatesCubit {}

void main() {
  late MockShoppingListCubit mockShoppingCubit;
  late MockShoppingTemplatesCubit mockTemplatesCubit;
  late MockThemeCubit mockThemeCubit;
  final humanizeNumbers = HumanizeNumbers();

  setUp(() {
    mockShoppingCubit = MockShoppingListCubit();
    mockTemplatesCubit = MockShoppingTemplatesCubit();
    mockThemeCubit = MockThemeCubit();

    when(() => mockTemplatesCubit.state).thenReturn(const ShoppingTemplatesState());
    when(() => mockTemplatesCubit.stream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest(ShoppingListItem item) {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<ShoppingListCubit>.value(value: mockShoppingCubit),
            BlocProvider<ShoppingTemplatesCubit>.value(value: mockTemplatesCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
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
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      
      expect(find.text('x1'), findsNothing);
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
    });

    testWidgets('Si TIENE precio y cantidad 1: muestra precio y oculta precio/ud', (tester) async {
      const item = ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, quantity: 1);

      await tester.pumpWidget(createWidgetUnderTest(item));

      // 1.5 -> "1,5€" con el nuevo formato (sin ceros innecesarios)
      expect(find.text('1,5€'), findsOneWidget);
      expect(find.text('x1'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      
      expect(find.textContaining('€/ud'), findsNothing);
    });

    testWidgets('Si TIENE precio y cantidad > 1: muestra precio total y unitario', (tester) async {
      const item = ShoppingListItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, quantity: 2);

      await tester.pumpWidget(createWidgetUnderTest(item));

      // 1.5 * 2 = 3.0 -> "3€"
      expect(find.text('3€'), findsOneWidget);
      // Unitario: 1.5 -> "1,5€/ud"
      expect(find.text('1,5€/ud'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });
  });
}
