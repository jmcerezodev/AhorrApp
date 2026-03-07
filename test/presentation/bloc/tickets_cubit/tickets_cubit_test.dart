import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
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

void main() {
  late TicketsCubit ticketsCubit;
  late MockGetTicketItemsUseCase mockGetItems;
  late MockSaveTicketItemUseCase mockSaveItem;
  late MockDeleteTicketItemUseCase mockDeleteItem;
  late MockClearTicketsUseCase mockClearItems;
  late MockReorderTicketItemsUseCase mockReorderItems;
  late MockProcessTicketImageUseCase mockProcessImage;

  final tItems = [
    const TicketItem(id: '1', userId: 'u1', name: 'Product 1', amount: 10.0, quantity: 1, category: 'general'),
  ];

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'uId': 'u1'});
    await Preferences.init();
    registerFallbackValue(const TicketItem(id: '0', userId: '', name: '', amount: 0, quantity: 0, category: ''));
  });

  setUp(() {
    mockGetItems = MockGetTicketItemsUseCase();
    mockSaveItem = MockSaveTicketItemUseCase();
    mockDeleteItem = MockDeleteTicketItemUseCase();
    mockClearItems = MockClearTicketsUseCase();
    mockReorderItems = MockReorderTicketItemsUseCase();
    mockProcessImage = MockProcessTicketImageUseCase();

    ticketsCubit = TicketsCubit(
      getTicketItemsUseCase: mockGetItems,
      saveTicketItemUseCase: mockSaveItem,
      deleteTicketItemUseCase: mockDeleteItem,
      clearTicketsUseCase: mockClearItems,
      reorderTicketItemsUseCase: mockReorderItems,
      processTicketImageUseCase: mockProcessImage,
    );
  });

  tearDown(() => ticketsCubit.close());

  test('initial state should be correct', () {
    expect(ticketsCubit.state, const TicketsState());
  });

  test('loadItems emits [loading, success] when successful', () async {
    when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);

    final expectedStates = [
      const TicketsState(status: TicketsStatus.loading),
      TicketsState(status: TicketsStatus.success, items: tItems),
    ];

    expectLater(ticketsCubit.stream, emitsInOrder(expectedStates));

    await ticketsCubit.loadItems();
  });

  test('addItem calls usecase and reloads items', () async {
    when(() => mockSaveItem.call(any())).thenAnswer((_) async => {});
    when(() => mockGetItems.call(any())).thenAnswer((_) async => tItems);

    await ticketsCubit.addItem(tItems[0]);

    verify(() => mockSaveItem.call(tItems[0])).called(1);
    verify(() => mockGetItems.call(any())).called(1);
  });

  test('deleteItem calls usecase and reloads items', () async {
    when(() => mockDeleteItem.call(any())).thenAnswer((_) async => {});
    when(() => mockGetItems.call(any())).thenAnswer((_) async => []);

    await ticketsCubit.deleteItem('1');

    verify(() => mockDeleteItem.call('1')).called(1);
    verify(() => mockGetItems.call(any())).called(1);
  });

  test('clearAll calls usecase and reloads items', () async {
    when(() => mockClearItems.call(any())).thenAnswer((_) async => {});
    when(() => mockGetItems.call(any())).thenAnswer((_) async => []);

    await ticketsCubit.clearAll();

    verify(() => mockClearItems.call(any())).called(1);
    verify(() => mockGetItems.call(any())).called(1);
  });
}
