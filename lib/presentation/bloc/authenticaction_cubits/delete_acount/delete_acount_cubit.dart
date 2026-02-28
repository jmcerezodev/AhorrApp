import 'package:flutter_bloc/flutter_bloc.dart';

part 'delete_acount_state.dart';

class DeleteAcountCubit extends Cubit<DeleteCubitState> {
  DeleteAcountCubit() : super(const DeleteCubitState());

  void inputValueDeleteAcount(String value){
    emit(state.copywith(
      deleteAcountValueInput: value,
    ));
  }

  
}
