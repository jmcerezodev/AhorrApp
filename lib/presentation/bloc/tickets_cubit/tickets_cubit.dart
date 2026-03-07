import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/shared_preferences/preferences.dart';
import '../../../domain/entities/ticket_item.dart';
import '../../../domain/usecases/tickets/get_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/save_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/delete_ticket_item_usecase.dart';
import '../../../domain/usecases/tickets/clear_tickets_usecase.dart';
import '../../../domain/usecases/tickets/reorder_ticket_items_usecase.dart';
import '../../../domain/usecases/tickets/process_ticket_image_usecase.dart';

part 'tickets_state.dart';

class TicketsCubit extends Cubit<TicketsState> {
  final GetTicketItemsUseCase getTicketItemsUseCase;
  final SaveTicketItemUseCase saveTicketItemUseCase;
  final DeleteTicketItemUseCase deleteTicketItemUseCase;
  final ClearTicketsUseCase clearTicketsUseCase;
  final ReorderTicketItemsUseCase reorderTicketItemsUseCase;
  final ProcessTicketImageUseCase processTicketImageUseCase;

  TicketsCubit({
    required this.getTicketItemsUseCase,
    required this.saveTicketItemUseCase,
    required this.deleteTicketItemUseCase,
    required this.clearTicketsUseCase,
    required this.reorderTicketItemsUseCase,
    required this.processTicketImageUseCase,
  }) : super(const TicketsState());

  Future<void> loadItems() async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      final items = await getTicketItemsUseCase(Preferences.uId);
      emit(state.copyWith(status: TicketsStatus.success, items: items));
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> processTicketImage(File imageFile) async {
    emit(state.copyWith(status: TicketsStatus.loading));
    try {
      final detectedItems = await processTicketImageUseCase(imageFile, Preferences.uId);
      
      for (var item in detectedItems) {
        await saveTicketItemUseCase(item);
      }
      
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: "Error al procesar ticket: $e"));
    }
  }

  Future<void> addItem(TicketItem item) async {
    try {
      await saveTicketItemUseCase(item);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateItem(TicketItem item) async {
    try {
      await saveTicketItemUseCase(item);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await deleteTicketItemUseCase(id);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> clearAll() async {
    try {
      await clearTicketsUseCase(Preferences.uId);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    final items = List<TicketItem>.from(state.items);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    emit(state.copyWith(items: items)); // Optimistic UI
    
    try {
      await reorderTicketItemsUseCase(items);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: TicketsStatus.failure, errorMessage: e.toString()));
    }
  }
}
