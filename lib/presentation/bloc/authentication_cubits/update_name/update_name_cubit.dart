import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/authentication_inputs/name_input.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'update_name_state.dart';

class UpdateNameCubit extends Cubit<UpdateNameState> {
  final LocalDbService _localDb = getIt<LocalDbService>();
  final SyncService _syncService = getIt<SyncService>();

  UpdateNameCubit() : super(UpdateNameState(name: Preferences.name));

  Future<void> onSubmit() async {
    if (!state.isValid) return;
    
    final String newName = state.newName.value;
    emit(state.copyWith(status: UpdateNameStatus.submitting));

    try {
      // 1. Actualización optimista local
      Preferences.name = newName;

      // 2. Registro en la cola de sincronización
      await _localDb.addPendingSync(
        'update_name', 
        'user', 
        {'name': newName}
      );

      // 3. Intento de sincronización inmediata
      _syncService.processQueue();

      emit(state.copyWith(
        name: newName,
        status: UpdateNameStatus.success,
        newName: const Name.pure(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UpdateNameStatus.failure,
        errorMessage: 'Error inesperado al actualizar el nombre localmente'
      ));
    }
  }

  void resetCubit() {
    emit(UpdateNameState(
      name: Preferences.name,
      newName: const Name.pure(),
      status: UpdateNameStatus.initial,
    ));
  }

  void newNameChanged(String value) {
    final newName = Name.dirty(value: value);
    emit(
      state.copyWith(
        newName: newName,
        isValid: Formz.validate([newName]),
        status: UpdateNameStatus.initial,
      )
    );    
  }
}
