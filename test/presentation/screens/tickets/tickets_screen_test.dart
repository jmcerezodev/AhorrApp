import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_cubit.dart';
import 'package:ahorrapp/presentation/bloc/theme_cubit/theme_state.dart';
import 'package:ahorrapp/presentation/screens/tickets_screen.dart';
import 'package:ahorrapp/presentation/widgets/shared/empty_list_widget.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/tickets_summary_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../helpers/mocks.dart';
import '../../../helpers/mock_platform.dart';

class MockTicketsCubit extends Mock implements TicketsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTicketsCubit mockTicketsCubit;
  late MockThemeCubit mockThemeCubit;

  setUpAll(() {
    setupMockPlatform();
  });

  setUp(() {
    mockTicketsCubit = MockTicketsCubit();
    mockThemeCubit = MockThemeCubit();
    
    when(() => mockTicketsCubit.state).thenReturn(TicketsState(
      status: TicketsStatus.success,
      items: [
        TicketItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'alimentación', date: DateTime.now()),
      ],
    ));
    when(() => mockTicketsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTicketsCubit.loadItems()).thenAnswer((_) async => {});
    when(() => mockTicketsCubit.updateSearchQuery(any())).thenReturn(null);
    when(() => mockTicketsCubit.scanAndProcessTicket()).thenAnswer((_) async => {});

    when(() => mockThemeCubit.state).thenReturn(ThemeState(
      themeMode: ThemeMode.light,
      isPrivacyModeActive: false,
    ));
    when(() => mockThemeCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  void setupScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<TicketsCubit>.value(value: mockTicketsCubit),
            BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
          ],
          child: const TicketsScreen(),
        ),
      ),
    );
  }

  group('TicketsScreen Widget Tests', () {
    testWidgets('Debe mostrar el título y el subtítulo en el AppBar', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('GUARDA TUS TICKETS'), findsOneWidget);
      expect(find.text('Digitaliza tus compras.'), findsOneWidget);
    });

    testWidgets('Debe utilizar animaciones de entrada', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(FadeInDown), findsWidgets);
      expect(find.byType(FadeInUp), findsOneWidget);
    });

    testWidgets('La tarjeta de resumen debe mostrar el botón ESCANEAR', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ESCANEAR'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    });

    testWidgets('Debe mostrar "TOTAL ESCANEADOS" en el resumen', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('TOTAL ESCANEADOS'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Debe mostrar la barra de búsqueda y llamar a updateSearchQuery al escribir', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      
      await tester.enterText(searchField, 'Mercadona');
      verify(() => mockTicketsCubit.updateSearchQuery('Mercadona')).called(1);
    });

    testWidgets('Debe mostrar EmptyListWidget si no hay items', (WidgetTester tester) async {
      setupScreenSize(tester);
      when(() => mockTicketsCubit.state).thenReturn(const TicketsState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TicketsSummaryWidget), findsOneWidget);
      expect(find.byType(EmptyListWidget), findsOneWidget);
    });

    testWidgets('Los items de la lista deben ser Dismissible (deslizables)', (WidgetTester tester) async {
      setupScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible), findsWidgets);
    });
  });
}
