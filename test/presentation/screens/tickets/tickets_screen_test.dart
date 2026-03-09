import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/screens/tickets_screen.dart';
import 'package:ahorrapp/presentation/widgets/tickets_screen/tickets_summary_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketsCubit extends Mock implements TicketsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTicketsCubit mockTicketsCubit;

  setUpAll(() {
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getDeviceInfo') {
        return {
          'computerName': 'Test-PC',
          'numberOfCores': 4,
          'systemMemoryInMegabytes': 8192,
        };
      }
      return null;
    });
  });

  setUp(() {
    mockTicketsCubit = MockTicketsCubit();
    
    when(() => mockTicketsCubit.state).thenReturn(TicketsState(
      status: TicketsStatus.success,
      items: [
        TicketItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, category: 'alimentación', date: DateTime.now()),
      ],
    ));
    when(() => mockTicketsCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTicketsCubit.loadItems()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<TicketsCubit>.value(
          value: mockTicketsCubit,
          child: const TicketsScreen(),
        ),
      ),
    );
  }

  group('TicketsScreen Widget Tests', () {
    testWidgets('Debe mostrar el título y el subtítulo en el AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ESCÁNER DE TICKETS'), findsOneWidget);
      expect(find.text('Digitaliza tus compras.'), findsOneWidget);
    });

    testWidgets('Debe utilizar animaciones de entrada (FadeInDown)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 1000));
      
      expect(find.byType(FadeInDown), findsWidgets);
    });

    testWidgets('La tarjeta de resumen debe mostrar el botón ESCANEAR', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('ESCANEAR'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    });

    testWidgets('Debe mostrar "TOTAL ESCANEADOS" en el resumen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('TOTAL ESCANEADOS'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Verifica el contador de tickets
    });

    testWidgets('Debe mostrar el estado vacío si no hay items', (WidgetTester tester) async {
      when(() => mockTicketsCubit.state).thenReturn(const TicketsState(items: []));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TicketsSummaryWidget), findsOneWidget);
      expect(find.text('SIN TICKETS'), findsOneWidget);
    });

    testWidgets('Los items de la lista deben tener un padding inferior de 8 para consistencia', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      final paddingFinder = find.byType(Padding);
      bool found8Padding = false;
      
      for (var widget in tester.widgetList<Padding>(paddingFinder)) {
        if (widget.padding is EdgeInsets && (widget.padding as EdgeInsets).bottom == 8) {
          found8Padding = true;
          break;
        }
      }
      expect(found8Padding, isTrue);
    });
  });
}
