import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'delete_acount_state.dart';

class DeleteAcountCubit extends Cubit<DeleteCubitState> {
  final AuthAppwrite _auth = AuthAppwrite();

  DeleteAcountCubit() : super(const DeleteCubitState());

  void inputValueDeleteAcount(String value) {
    // CORREGIDO: copyWith con W mayúscula y parámetro 'status'
    emit(state.copyWith(
      deleteAcountValueInput: value,
      status: DeleteAccountStatus.initial,
    ));
  }

  void onSubmit(BuildContext context) async {
    if (state.deleteAcountValueInput != 'ELIMINAR MI CUENTA') {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Confirmación incorrecta',
      ));
      return;
    }

    emit(state.copyWith(status: DeleteAccountStatus.submitting));

    try {
      await _auth.deleteAcount(context);
      emit(state.copyWith(status: DeleteAccountStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DeleteAccountStatus.failure,
        errorMessage: 'Error al eliminar la cuenta',
      ));
    }
  }
}
