import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'delete_acount_state.dart';

class DeleteAcountCubit extends Cubit<DeleteCubitState> {
  final AuthAppwrite _auth = AuthAppwrite();

  DeleteAcountCubit() : super(const DeleteCubitState());

  void inputValueDeleteAcount(String value) {
    emit(state.copyWith(
      deleteAcountValueInput: value,
      status: DeleteAccountStatus.initial,
    ));
  }

  void onSubmit(BuildContext context) async {
    // Blindaje: Validamos que la contraseña introducida coincida con la del usuario actual
    if (state.deleteAcountValueInput != Preferences.password) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Contraseña incorrecta',
      ));
      return;
    }

    emit(state.copyWith(status: DeleteAccountStatus.submitting, deleteProgress: 0.0));

    try {
      await _auth.deleteAcount(
        context,
        onProgress: (progress) {
          emit(state.copyWith(deleteProgress: progress));
        },
      );
      emit(state.copyWith(status: DeleteAccountStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Error al eliminar la cuenta',
      ));
    }
  }
}
