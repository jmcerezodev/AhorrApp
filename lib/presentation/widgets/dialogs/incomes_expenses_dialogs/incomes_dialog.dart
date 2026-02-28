import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IncomesDialog extends StatefulWidget {
  const IncomesDialog({super.key});

  @override
  State<IncomesDialog> createState() => _IncomesDialogState();
}

class _IncomesDialogState extends State<IncomesDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomesCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = Date();
    final AppwriteRepository appwriteRepo = AppwriteRepository();
    final incomesCubit = context.watch<IncomesCubit>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.green.shade100, width: 1.5),
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
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up_rounded, color: Colors.green.shade700, size: 24),
                ),
                const SizedBox(width: 15),
                const Text(
                  'NUEVO INGRESO',
                  style: TextStyle(
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
              label: 'Origen del ingreso',
              hintText: 'Ej. Nómina, Bizum...',
              onChanged: incomesCubit.incomeNameChanged,
              errorText: incomesCubit.state.incomeName.isPure ? null : incomesCubit.state.incomeName.errorMessage,
              textInputType: TextInputType.name,
            ),
            const SizedBox(height: 15),
            CustomInputTextWidget(
              label: 'Importe',
              hintText: '0.00',
              onChanged: incomesCubit.incomeMoneyChanged,
              errorText: incomesCubit.state.incomeMoney.isPure ? null : incomesCubit.state.incomeMoney.errorMessage,
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
                    onPressed: (incomesCubit.state.isValid) 
                    ? () async {
                      incomesCubit.onSubmit();
                      await appwriteRepo.addHistory(
                        userId: Preferences.uId,
                        name: incomesCubit.state.incomeName.value,
                        money: double.parse(incomesCubit.state.incomeMoney.value.replaceAll(',', '.')),
                        isIncome: true,
                        currentDate: date.currentDate(),
                        currentHour: date.currentHour(),
                        month: date.monthNames(),
                        year: int.parse(date.year()),
                      );
                      if (context.mounted) {
                        await context.read<HistoryCubit>().loadHistory();
                        incomesCubit.resetCubit();
                        context.pop();
                      }
                    }
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
