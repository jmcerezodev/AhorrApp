import 'dart:io';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/services/document_scanner_service.dart';
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
class MockReorderTicketItemsUseCase extends Mock implements ReorderTicketItemsUseCase {}
class MockProcessTicketImageUseCase extends Mock implements ProcessTicketImageUseCase {}
class MockDocumentScannerService extends Mock implements DocumentScannerService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late TicketsCubit ticketsCubit;
  late MockGetTicketItemsUseCase mockGetItems;
  late MockSaveTicketItemUseCase mockSaveItem;
  late MockDeleteTicketItemUseCase mockDeleteItem;
  late MockReorderTicketItemsUseCase mockReorderItems;
  late MockProcessTicketImageUseCase mockProcessImage;
  late MockDocumentScannerService mockScannerService;

  final tDate = DateTime(2023, 1, 1);
  final tItems = [
    TicketItem(id: '1', userId: 'u1', name: 'Leche', amount: 1.5, date: tDate, category: 'alimentación'),
    TicketItem(id: '2', userId: 'u1', name: 'Carne', amount: 10.0, date: tDate, category: 'comida'),
  ];

  setUpAll(() {
    registerFallbackValue(TicketItem(id: '0', userId: '', name: '', amount: 0, date: DateTime.now(), category: ''));
    registerFallbackValue(File(''));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'u1'});
    await Preferences.init();

    mockGetItems = MockGetTicketItemsUseCase();
    mockSaveItem = MockSaveTicketItemUseCase();
    mockDeleteItem = MockDeleteTicketItemUseCase();
    mockReorderItems = MockReorderTicketItemsUseCase();
    mockProcessImage = MockProcessTicketImageUseCase();
    mockScannerService = MockDocumentScannerService();

    ticketsCubit = TicketsCubit(
      getTicketItemsUseCase: mockGetItems,
      saveTicketItemUseCase: mockSaveItem,
      deleteTicketItemUseCase: mockDeleteItem,
      reorderTicketItemsUseCase: mockReorderItems,
      processTicketImageUseCase: mockProcessImage,
      documentScannerService: mockScannerService,
    );
  });

  tearDown(() => ticketsCubit.close());

  group('TicketsCubit - Lógica de Búsqueda, Filtrado y Ordenación', () {
    test('filteredItems debe retornar todos los items ordenados por fecha descendente si la búsqueda está vacía', () async {
      final oldTicket = TicketItem(id: 'old', userId: 'u1', name: 'A', amount: 1, date: DateTime(2023, 1, 1), category: 'g');
      final newTicket = TicketItem(id: 'new', userId: 'u1', name: 'B', amount: 1, date: DateTime(2023, 1, 2), category: 'g');
      
      when(() => mockGetItems.call(any())).thenAnswer((_) async => [oldTicket, newTicket]);
      await ticketsCubit.loadItems();
      
      expect(ticketsCubit.state.filteredItems.first.id, 'new');
      expect(ticketsCubit.state.filteredItems.last.id, 'old');
    });

    test('filteredItems debe filtrar correctamente por nombre (case insensitive)', () async {
      when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);
      await ticketsCubit.loadItems();
      
      ticketsCubit.updateSearchQuery('leche');
      expect(ticketsCubit.state.filteredItems.length, 1);
      expect(ticketsCubit.state.filteredItems.first.name, 'Leche');
    });

    test('filteredItems debe filtrar correctamente por categoría', () async {
      when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);
      await ticketsCubit.loadItems();
      
      ticketsCubit.updateSearchQuery('comida');
      expect(ticketsCubit.state.filteredItems.length, 1);
      expect(ticketsCubit.state.filteredItems.first.category, 'comida');
    });

    test('filteredItems debe retornar lista vacía si no hay coincidencias', () async {
      when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);
      await ticketsCubit.loadItems();
      
      ticketsCubit.updateSearchQuery('inexistente');
      expect(ticketsCubit.state.filteredItems, isEmpty);
    });
  });

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
      
      when(() => mockGetItems.call(any())).thenAnswer((_) async => initialItems);
      when(() => mockReorderItems.call(any())).thenAnswer((_) async => {});
      
      await ticketsCubit.loadItems();
      when(() => mockGetItems.call(any())).thenAnswer((_) async => reorderedItems);

      await ticketsCubit.reorderItems(0, 2);

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

    test('updateItem llama usecase y marca como transferido correctamente', () async {
      final transferredItem = tItems[0].copyWith(isTransferred: true);
      when(() => mockSaveItem.call(any())).thenAnswer((_) async => {});
      when(() => mockGetItems.call(any())).thenAnswer((_) async => [transferredItem]);

      await ticketsCubit.updateItem(transferredItem);

      verify(() => mockSaveItem.call(transferredItem)).called(1);
      expect(ticketsCubit.state.items.first.isTransferred, isTrue);
    });

    test('deleteItem llama usecase y recarga items', () async {
      when(() => mockDeleteItem.call(any())).thenAnswer((_) async => {});
      when(() => mockGetItems.call(any())).thenAnswer((_) async => []);

      await ticketsCubit.deleteItem('1');

      verify(() => mockDeleteItem.call('1')).called(1);
      verify(() => mockGetItems.call(any())).called(1);
    });
  });
}
