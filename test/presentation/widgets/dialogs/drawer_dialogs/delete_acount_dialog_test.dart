import 'package:ahorrapp/presentation/bloc/authentication_cubits/delete_acount/delete_acount_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/drawer_dialogs/delete_acount_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDeleteAcountCubit extends Mock implements DeleteAcountCubit {}

void main() {
  late MockDeleteAcountCubit mockCubit;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'password': 'password123'});
    await Preferences.init();
  });

  setUp(() {
    mockCubit = MockDeleteAcountCubit();

    // Estado inicial
    when(() => mockCubit.state).thenReturn(const DeleteCubitState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    
    when(() => mockCubit.inputValueDeleteAcount(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DeleteAcountCubit>.value(
          value: mockCubit,
          child: const DeleteAcountDialog(
            title: 'Eliminar Cuenta',
            text: 'Esta acción es irreversible',
          ),
        ),
      ),
    );
  }

  group('DeleteAcountDialog - Pruebas de Interfaz Crítica', () {
    testWidgets('Debe mostrar el título en rojo y el icono de advertencia', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('ELIMINAR CUENTA'), findsOneWidget);
      expect(find.byIcon(Icons.no_accounts_rounded), findsOneWidget);
    });

    testWidgets('Debe permitir escribir en el campo de confirmación', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'mi-password');
      
      verify(() => mockCubit.inputValueDeleteAcount('mi-password')).called(1);
    });

    testWidgets('Debe mostrar los botones de cancelar y eliminar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('CANCELAR'), findsOneWidget);
      expect(find.text('ELIMINAR'), findsOneWidget);
    });
   group('Visualización de Alertas', () {
      testWidgets('El botón ELIMINAR debe tener fondo rojo', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        
        final elevatedButton = tester.widget<ElevatedButton>(
          find.ancestor(of: find.text('ELIMINAR'), matching: find.byType(ElevatedButton))
        );
        
        expect(elevatedButton.style?.backgroundColor?.resolve({}), Colors.red.shade400);
      });
    });
  });
}
