import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteItemHistoryDialog extends StatelessWidget {
  final String itemId;
  
  const DeleteItemHistoryDialog({
    super.key, 
    required this.itemId
  });

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final appwriteRepo = AppwriteRepository();
    bool isIncomeResult = false;

    final itemResult = historyCubit.state.historyList.firstWhere(
      (map) => map["id"] == itemId, 
      orElse: () => {}
    );
    
    if(itemResult.isNotEmpty){
      isIncomeResult = itemResult['isIncome'];
    }
      
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.red.shade100, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de advertencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 32),
            ),
            const SizedBox(height: 20),
            
            Text(
              isIncomeResult ? '¿ELIMINAR INGRESO?' : '¿ELIMINAR GASTO?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            
            Text(
              'Esta acción no se puede deshacer.\n¿Estás seguro de que quieres borrar este registro del historial?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
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
                    onPressed: () async {
                      await appwriteRepo.deleteHistory(itemId);
                      if (context.mounted) {
                        context.read<HistoryCubit>().loadHistory();
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
