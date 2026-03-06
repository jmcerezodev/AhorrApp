import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/delete_shopping_template_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/get_shopping_templates_usecase.dart';
import 'package:ahorrapp/domain/usecases/shopping_list/save_shopping_template_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'shopping_templates_state.dart';

class ShoppingTemplatesCubit extends Cubit<ShoppingTemplatesState> {
  final GetShoppingTemplatesUseCase _getTemplatesUseCase;
  final SaveShoppingTemplateUseCase _saveTemplateUseCase;
  final DeleteShoppingTemplateUseCase _deleteTemplateUseCase;

  ShoppingTemplatesCubit({
    required GetShoppingTemplatesUseCase getTemplatesUseCase,
    required SaveShoppingTemplateUseCase saveTemplateUseCase,
    required DeleteShoppingTemplateUseCase deleteTemplateUseCase,
  })  : _getTemplatesUseCase = getTemplatesUseCase,
        _saveTemplateUseCase = saveTemplateUseCase,
        _deleteTemplateUseCase = deleteTemplateUseCase,
        super(const ShoppingTemplatesState());

  Future<void> loadTemplates() async {
    emit(state.copyWith(status: ShoppingTemplatesStatus.loading));
    try {
      final templates = await _getTemplatesUseCase(Preferences.uId);
      emit(state.copyWith(
        templates: templates,
        status: ShoppingTemplatesStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ShoppingTemplatesStatus.failure,
        errorMessage: 'Error al cargar favoritos: $e',
      ));
    }
  }

  Future<void> updateOrSaveFavorite({
    String? id,
    required String name,
    required double amount,
    required String category,
  }) async {
    emit(state.copyWith(status: ShoppingTemplatesStatus.loading));
    
    final template = ShoppingTemplate(
      id: id ?? const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      items: [
        ShoppingTemplateItem(name: name, amount: amount, category: category)
      ],
    );

    try {
      await _saveTemplateUseCase(template);
      await loadTemplates();
    } catch (e) {
      emit(state.copyWith(
        status: ShoppingTemplatesStatus.failure,
        errorMessage: 'Error al procesar favorito: $e',
      ));
    }
  }

  Future<void> saveTemplate(String name, List<ShoppingTemplateItem> items) async {
    if (state.isFavorite(name)) return;

    emit(state.copyWith(status: ShoppingTemplatesStatus.loading));
    final template = ShoppingTemplate(
      id: const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      items: items,
    );

    try {
      await _saveTemplateUseCase(template);
      await loadTemplates();
    } catch (e) {
      emit(state.copyWith(
        status: ShoppingTemplatesStatus.failure,
        errorMessage: 'Error al guardar favorito: $e',
      ));
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _deleteTemplateUseCase(id);
      await loadTemplates();
    } catch (e) {
      emit(state.copyWith(
        status: ShoppingTemplatesStatus.failure,
        errorMessage: 'Error al eliminar favorito: $e',
      ));
    }
  }
}
