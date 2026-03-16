import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class QuickPriceDialog extends StatefulWidget {
  final ShoppingListItem item;
  const QuickPriceDialog({super.key, required this.item});

  @override
  State<QuickPriceDialog> createState() => _QuickPriceDialogState();
}

class _QuickPriceDialogState extends State<QuickPriceDialog> {
  late TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: Icons.euro_rounded, 
            title: 'Añadir Precio', 
            color: Colors.orange, 
            colorScheme: colorScheme
          ),
          SizedBox(height: 10.h),
          Text(
            widget.item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 25.h),
          
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 10.h : 0),
              child: CustomInputTextWidget(
                controller: _amountController,
                label: 'Importe del producto',
                hintText: '0',
                autoFocus: true,
                textInputType: const TextInputType.numberWithOptions(decimal: false),
                enabled: !_isLoading,
              ),
            ),
          ),
          
          SizedBox(height: 30.h),

          OverflowBar(
            spacing: 15.w,
            overflowSpacing: 10.h,
            alignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120.w,
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(), 
                  colorScheme: colorScheme
                ),
              ),
              SizedBox(
                width: 120.w,
                child: AppDialogs.dialogPrimaryButton(
                  text: 'GUARDAR', 
                  onPressed: _isLoading ? null : _save, 
                  color: Colors.orange,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _save() async {
    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    
    // REGLA DE ORO: Guardamos como entero
    final updatedItem = widget.item.copyWith(amount: amount.toInt().toDouble());
    await context.read<ShoppingListCubit>().updateItem(updatedItem);
    
    if (mounted) context.pop();
  }
}
