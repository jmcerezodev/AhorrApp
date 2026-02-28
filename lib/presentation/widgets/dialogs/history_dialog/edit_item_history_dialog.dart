import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditItemHistoryDialog extends StatefulWidget {
  final String itemId;
  
  const EditItemHistoryDialog({
    super.key,
    required this.itemId
  });

  @override
  State<EditItemHistoryDialog> createState() => _EditItemHistoryDialogState();
}

class _EditItemHistoryDialogState extends State<EditItemHistoryDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appwriteRepo = AppwriteRepository();
    final historyCubit = context.watch<HistoryCubit>();

    Map<String, dynamic> itemResult = historyCubit.state.historyList.firstWhere(
      (map) => map["id"] == widget.itemId, 
      orElse: () => {}
    );
    
    if (itemResult.isEmpty) return const SizedBox();

    final isIncomeResult = itemResult['isIncome'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blueGrey.shade50, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono y Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit_note_rounded, color: Colors.blueGrey.shade700, size: 24),
                ),
                const SizedBox(width: 15),
                Text(
                  isIncomeResult ? 'EDITAR INGRESO' : 'EDITAR GASTO',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Nuevo concepto',
              hintText: itemResult['name'],
              onChanged: historyCubit.newNameChanged,
              errorText: historyCubit.state.newName.isPure ? null : historyCubit.state.newName.errorMessage,
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            CustomInputTextWidget(
              label: 'Nuevo importe',
              hintText: itemResult['money'].toString(),
              onChanged: historyCubit.newMoneyChanged,
              errorText: historyCubit.state.newMoney.isPure ? null : historyCubit.state.newMoney.errorMessage,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text('CANCELAR', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (historyCubit.state.newName.isValid || historyCubit.state.newMoney.isValid) 
                    ? () async {
                        final Map<String, dynamic> updateData = {};
                        if (historyCubit.state.newName.isValid) {
                          updateData['name'] = historyCubit.state.newName.value;
                        }
                        if (historyCubit.state.newMoney.isValid) {
                          updateData['money'] = double.parse(historyCubit.state.newMoney.value.replaceAll(',', '.'));
                        }

                        if (updateData.isNotEmpty) {
                          await appwriteRepo.updateHistory(
                            documentId: widget.itemId, 
                            data: updateData
                          );
                          if (context.mounted) {
                            await context.read<HistoryCubit>().loadHistory();
                            historyCubit.resetCubit();
                            context.pop();
                          }
                        }
                    }
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('ACTUALIZAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
