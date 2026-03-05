import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_list_item_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_list_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_list_item_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingState> {
  final GetShoppingListUseCase _getShoppingListUseCase = getIt<GetShoppingListUseCase>();
  final SaveShoppingListItemUseCase _saveShoppingItemUseCase = getIt<SaveShoppingListItemUseCase>();
  final DeleteShoppingListItemUseCase _deleteShoppingItemUseCase = getIt<DeleteShoppingListItemUseCase>();

  ShoppingListCubit() : super(const ShoppingState());

  Future<void> loadItems() async {
    emit(state.copyWith(status: ShoppingStatus.loading));
    try {
      final items = await _getShoppingListUseCase(Preferences.uId);
      emit(state.copyWith(items: items, status: ShoppingStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> addItem(String name, {double amount = 0.0, String category = 'general'}) async {
    final newItem = ShoppingListItem(
      id: const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      amount: amount,
      category: category,
      position: state.items.length,
    );

    try {
      await _saveShoppingItemUseCase(newItem);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleItem(ShoppingListItem item) async {
    final updatedItem = item.copyWith(isBought: !item.isBought);
    try {
      await _saveShoppingItemUseCase(updatedItem);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateItem(ShoppingListItem item) async {
    try {
      await _saveShoppingItemUseCase(item);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _deleteShoppingItemUseCase(id);
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> clearBoughtItems() async {
    final boughtItems = state.items.where((item) => item.isBought).toList();
    try {
      for (var item in boughtItems) {
        await _deleteShoppingItemUseCase(item.id);
      }
      await loadItems();
    } catch (e) {
      emit(state.copyWith(status: ShoppingStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;

    final List<ShoppingListItem> items = List.from(state.items);
    final ShoppingListItem item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    final List<ShoppingListItem> updatedItems = [];
    for (int i = 0; i < items.length; i++) {
      updatedItems.add(items[i].copyWith(position: i));
    }

    emit(state.copyWith(items: updatedItems));

    try {
      for (var item in updatedItems) {
        await _saveShoppingItemUseCase(item);
      }
    } catch (e) {
      await loadItems();
    }
  }
}
