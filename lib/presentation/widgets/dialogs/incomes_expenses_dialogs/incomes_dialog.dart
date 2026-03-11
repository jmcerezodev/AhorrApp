import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
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

    return CustomDialogWrapper(
      borderColor: Colors.green.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: Icons.trending_up_rounded,
            title: 'Nuevo Ingreso',
            color: Colors.green.shade400,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 25),
    
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputTextWidget(
                    label: 'ORIGEN DEL INGRESO',
                    hintText: 'Ej. Nómina, Bizum...',
                    onChanged: incomesCubit.incomeNameChanged,
                    errorText: incomesCubit.state.incomeName.isPure ? null : incomesCubit.state.incomeName.errorMessage,
                    textInputType: TextInputType.name,
                    autoFocus: true,
                  ),
                  const SizedBox(height: 15),
                  CustomInputTextWidget(
                    label: 'IMPORTE',
                    hintText: '0.00',
                    onChanged: incomesCubit.incomeMoneyChanged,
                    errorText: incomesCubit.state.incomeMoney.isPure ? null : incomesCubit.state.incomeMoney.errorMessage,
                    textInputType: const TextInputType.numberWithOptions(decimal: true),
                    autoFocus: false,
                  ),
                  const SizedBox(height: 25),
            
                  Text('CATEGORÍA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
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
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    cat['name'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) => incomesCubit.categoryChanged(val ?? 'otro'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    
          const SizedBox(height: 30),
    
          Row(
            children: [
              Expanded(
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(), 
                  colorScheme: colorScheme
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'GUARDAR',
                  color: Colors.orange,
                  isLoading: incomesCubit.state.status == IncomesStatus.posting,
                  onPressed: (incomesCubit.state.isValid && incomesCubit.state.status != IncomesStatus.posting) 
                  ? () async {
                    await incomesCubit.saveIncome(historyCubit);
                    if (context.mounted && incomesCubit.state.status == IncomesStatus.success) {
                      context.pop();
                    }
                  }
                  : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
