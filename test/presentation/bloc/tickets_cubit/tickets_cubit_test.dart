import 'dart:io';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
import 'package:ahorrapp/domain/usecases/tickets/clear_tickets_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/delete_ticket_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/get_ticket_items_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/process_ticket_image_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/reorder_ticket_items_usecase.dart';
import 'package:ahorrapp/domain/usecases/tickets/save_ticket_item_usecase.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetTicketItemsUseCase extends Mock implements GetTicketItemsUseCase {}
class MockSaveTicketItemUseCase extends Mock implements SaveTicketItemUseCase {}
class MockDeleteTicketItemUseCase extends Mock implements DeleteTicketItemUseCase {}
class MockClearTicketsUseCase extends Mock implements ClearTicketsUseCase {}
class MockReorderTicketItemsUseCase extends Mock implements ReorderTicketItemsUseCase {}
class MockProcessTicketImageUseCase extends Mock implements ProcessTicketImageUseCase {}
class MockDocumentScannerService extends Mock implements DocumentScannerService {}

void main() {
  late TicketsCubit ticketsCubit;
  late MockGetTicketItemsUseCase mockGetItems;
  late MockSaveTicketItemUseCase mockSaveItem;
  late MockDeleteTicketItemUseCase mockDeleteItem;
  late MockClearTicketsUseCase mockClearItems;
  late MockReorderTicketItemsUseCase mockReorderItems;
  late MockProcessTicketImageUseCase mockProcessImage;
  late MockDocumentScannerService mockScannerService;

  final tDate = DateTime(2023, 1, 1);
  final tItems = [
    TicketItem(id: '1', userId: 'u1', name: 'Establecimiento 1', amount: 10.0, date: tDate, category: 'general'),
  ];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'uId': 'u1'});
    await Preferences.init();
    registerFallbackValue(TicketItem(id: '0', userId: '', name: '', amount: 0, date: DateTime.now(), category: ''));
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockGetItems = MockGetTicketItemsUseCase();
    mockSaveItem = MockSaveTicketItemUseCase();
    mockDeleteItem = MockDeleteTicketItemUseCase();
    mockClearItems = MockClearTicketsUseCase();
    mockReorderItems = MockReorderTicketItemsUseCase();
    mockProcessImage = MockProcessTicketImageUseCase();
    mockScannerService = MockDocumentScannerService();

    ticketsCubit = TicketsCubit(
      getTicketItemsUseCase: mockGetItems,
      saveTicketItemUseCase: mockSaveItem,
      deleteTicketItemUseCase: mockDeleteItem,
      clearTicketsUseCase: mockClearItems,
      reorderTicketItemsUseCase: mockReorderItems,
      processTicketImageUseCase: mockProcessImage,
      documentScannerService: mockScannerService,
    );
  });

  tearDown(() => ticketsCubit.close());

  group('TicketsCubit - Enhanced Flow & Calculation', () {
    test('initial state should be correct', () {
      expect(ticketsCubit.state, const TicketsState());
    });

    test('loadItems emite [loading, success] cuando es exitoso', () async {
      when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);
      final expectedStates = [
        const TicketsState(status: TicketsStatus.loading),
        TicketsState(status: TicketsStatus.success, items: tItems),
      ];
      expectLater(ticketsCubit.stream, emitsInOrder(expectedStates));
      await ticketsCubit.loadItems();
    });

    test('totalAmount debe calcular la suma dinámica correctamente', () {
      final multiItems = [
        TicketItem(id: '1', userId: 'u1', name: 'A', amount: 2.5, date: tDate, category: 'g'),
        TicketItem(id: '2', userId: 'u1', name: 'B', amount: 1.0, date: tDate, category: 'g'),
      ];
      final state = TicketsState(items: multiItems);
      expect(state.totalAmount, 3.5);
    });

    test('reorderItems debe reorganizar la lista localmente', () async {
      final itemA = TicketItem(id: '1', userId: 'u1', name: 'A', amount: 1.0, date: tDate, category: 'g', position: 0);
      final itemB = TicketItem(id: '2', userId: 'u1', name: 'B', amount: 2.0, date: tDate, category: 'g', position: 1);
      final initialItems = [itemA, itemB];
      final reorderedItems = [itemB, itemA];
      
      // Primera carga: devuelve orden original
      when(() => mockGetItems.call(any())).thenAnswer((_) async => initialItems);
      when(() => mockReorderItems.call(any())).thenAnswer((_) async => {});
      
      await ticketsCubit.loadItems();

      // Mock para la recarga tras reordenar: devuelve el nuevo orden
      when(() => mockGetItems.call(any())).thenAnswer((_) async => reorderedItems);

      await ticketsCubit.reorderItems(0, 2); // Mueve A (index 0) al final

      expect(ticketsCubit.state.items.first.id, '2');
      expect(ticketsCubit.state.items.last.id, '1');
    });

    test('addItem llama usecase y recarga items', () async {
      when(() => mockSaveItem.call(any())).thenAnswer((_) async => {});
      when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);

      await ticketsCubit.addItem(tItems[0]);

      verify(() => mockSaveItem.call(tItems[0])).called(1);
      verify(() => mockGetItems.call(any())).called(1);
    });

    test('deleteItem llama usecase y recarga items', () async {
      when(() => mockDeleteItem.call(any())).thenAnswer((_) async => {});
      when(() => mockGetItems.call(any())).thenAnswer((_) async => []);

      await ticketsCubit.deleteItem('1');

      verify(() => mockDeleteItem.call('1')).called(1);
      verify(() => mockGetItems.call(any())).called(1);
    });

    test('clearAll llama usecase y recarga items', () async {
      when(() => mockClearItems.call(any())).thenAnswer((_) async => {});
      when(() => mockGetItems.call(any())).thenAnswer((_) async => []);

      await ticketsCubit.clearAll();

      verify(() => mockClearItems.call(any())).called(1);
      verify(() => mockGetItems.call(any())).called(1);
    });
  });
}
