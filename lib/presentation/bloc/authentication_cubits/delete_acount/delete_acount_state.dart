part of 'delete_acount_cubit.dart';


class DeleteCubitState {


  final String deleteAcountValueInput;

  const DeleteCubitState({
    this.deleteAcountValueInput = '',
  });
  

  copywith ({
    String? deleteAcountValueInput,
  }) => DeleteCubitState(
    deleteAcountValueInput: deleteAcountValueInput ?? this.deleteAcountValueInput,
  );


}
