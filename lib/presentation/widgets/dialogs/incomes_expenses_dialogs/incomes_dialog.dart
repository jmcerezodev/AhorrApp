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
  final List<Map<String, dynamic>> _categories = [
    {'id': 'nómina', 'icon': Icons.work_rounded, 'name': 'Nómina'},
    {'id': 'bizum', 'icon': Icons.send_to_mobile_rounded, 'name': 'Bizum'},
    {'id': 'regalo', 'icon': Icons.card_giftcard_rounded, 'name': 'Regalo'},
    {'id': 'inversión', 'icon': Icons.show_chart_rounded, 'name': 'Inversión'},
    {'id': 'otro', 'icon': Icons.more_horiz_rounded, 'name': 'Otro'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomesCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomesCubit = context.watch<IncomesCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.green.shade400.withValues(alpha: isDark ? 0.2 : 0.4), 
              width: 1.5
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade400.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.trending_up_rounded, color: Colors.green.shade400, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'NUEVO INGRESO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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
              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Categoría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: incomesCubit.state.category,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(15),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Row(
                          children: [
                            Icon(cat['icon'], size: 16, color: Colors.green.shade400),
                            const SizedBox(width: 8),
                            Flexible(child: Text(cat['name'], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => incomesCubit.categoryChanged(val ?? 'otro'),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: incomesCubit.state.status == IncomesStatus.posting 
                        ? null 
                        : () => context.pop(),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: Text(
                        'CANCELAR', 
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4), 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (incomesCubit.state.isValid && incomesCubit.state.status != IncomesStatus.posting) 
                      ? () async {
                        await incomesCubit.saveIncome(historyCubit);
                        if (context.mounted && incomesCubit.state.status == IncomesStatus.success) {
                          context.pop();
                        }
                      }
                      : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: incomesCubit.state.status == IncomesStatus.posting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
