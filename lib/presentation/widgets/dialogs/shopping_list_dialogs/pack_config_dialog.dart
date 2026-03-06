import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/confirm_shopping_transfer_dialog.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PackConfigDialog extends StatefulWidget {
  final bool onlyPrices; 
  const PackConfigDialog({super.key, this.onlyPrices = false});

  @override
  State<PackConfigDialog> createState() => _PackConfigDialogState();
}

class _PackConfigDialogState extends State<PackConfigDialog> {
  late TextEditingController _nameController;
  final Map<String, TextEditingController> _priceControllers = {};
  bool _isFixingPrices = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Compra Supermercado');
    
    final shoppingState = context.read<ShoppingListCubit>().state;
    final itemsWithoutPrice = shoppingState.items.where((item) => item.isBought && item.amount <= 0).toList();
    
    for (var item in itemsWithoutPrice) {
      _priceControllers[item.id] = TextEditingController();
    }
    
    _isFixingPrices = itemsWithoutPrice.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showRequiredPricesDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    AppDialogs.showCustomDialog(
      context: context,
      builder: CustomDialogWrapper(
        borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogHeader(
              icon: Icons.error_outline_rounded, 
              color: Colors.red.shade400, 
              title: 'PRECIOS REQUERIDOS',
              circularBackground: true,
              iconSize: 32,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 15),
            AppDialogs.dialogMessage(
              'Es obligatorio añadir el precio a todos los productos para poder incluirlos en tu lista de gastos.', 
              colorScheme
            ),
            const SizedBox(height: 30),
            AppDialogs.dialogPrimaryButton(
              text: 'ENTENDIDO', 
              onPressed: () => Navigator.pop(context), 
              color: Colors.orange
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shoppingCubit = context.watch<ShoppingListCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final humanizeNumbers = HumanizeNumbers();

    return CustomDialogWrapper(
      horizontalInsetPadding: 20,
      borderColor: _isFixingPrices ? Colors.red.shade400.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: _isFixingPrices ? Icons.warning_amber_rounded : (widget.onlyPrices ? Icons.list_alt_rounded : Icons.inventory_2_rounded), 
            color: _isFixingPrices ? Colors.red.shade400 : Colors.orange, 
            title: _isFixingPrices ? 'FALTAN PRECIOS' : (widget.onlyPrices ? 'COMPLETAR PRECIOS' : 'CONFIGURAR PACK'),
            circularBackground: false,
            iconSize: 40,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          if (_isFixingPrices) ...[
            AppDialogs.dialogMessage('Añade el precio a los productos en la cesta.', colorScheme),
            const SizedBox(height: 20),
            ...shoppingCubit.state.items.where((item) => item.isBought && item.amount <= 0).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomInputTextWidget(
                controller: _priceControllers[item.id]!,
                label: item.name,
                hintText: '0.00€',
                textInputType: const TextInputType.numberWithOptions(decimal: true),
              ),
            )),
          ] else if (!widget.onlyPrices) ...[
            AppDialogs.dialogMessage('Indica un nombre para el pack de gastos.', colorScheme),
            const SizedBox(height: 20),
            CustomInputTextWidget(
              controller: _nameController,
              label: 'Nombre del Pack',
              hintText: 'Ej: Compra Mercadona',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL A GUARDAR', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: Colors.orange)),
                  Text(
                    '${humanizeNumbers.number(shoppingCubit.state.totalBoughtPrice)}€',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppDialogs.dialogMessage('Todos los productos tienen precio. ¿Quieres guardarlos individualmente?', colorScheme),
          ],

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.w900, 
                      fontSize: 12,
                      letterSpacing: 1
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: _isFixingPrices ? 'CONTINUAR' : 'GUARDAR',
                  color: Colors.orange,
                  onPressed: () async {
                    if (_isFixingPrices) {
                      bool allFilled = true;
                      for (var controller in _priceControllers.values) {
                        final p = double.tryParse(controller.text.replaceAll(',', '.'));
                        if (p == null || p <= 0) {
                          allFilled = false;
                          break;
                        }
                      }

                      if (!allFilled) {
                        _showRequiredPricesDialog();
                        return;
                      }

                      for (var entry in _priceControllers.entries) {
                        final price = double.parse(entry.value.text.replaceAll(',', '.'));
                        final item = shoppingCubit.state.items.firstWhere((i) => i.id == entry.key);
                        await shoppingCubit.updateItem(item.copyWith(amount: price));
                      }

                      if (widget.onlyPrices) {
                        final navigator = Navigator.of(context);
                        await shoppingCubit.transferToExpenses(asPack: false, historyCubit: historyCubit);
                        navigator.pop(); 
                        if (mounted) {
                          AppDialogs.showCustomDialog(
                            context: navigator.context, 
                            builder: CustomDialogWrapper(
                              borderColor: Colors.green.withValues(alpha: 0.4),
                              child: const ConfirmShoppingTransferDialog(message: 'Los productos se han añadido individualmente.')
                            )
                          );
                        }
                      } else {
                        setState(() => _isFixingPrices = false);
                      }
                    } else {
                      final navigator = Navigator.of(context);
                      final packName = _nameController.text.trim().isEmpty ? 'Compra Supermercado' : _nameController.text.trim();
                      
                      await shoppingCubit.transferToExpenses(
                        asPack: !widget.onlyPrices, 
                        historyCubit: historyCubit,
                        packName: widget.onlyPrices ? null : packName
                      );
                      
                      navigator.pop(); 
                      if (mounted) {
                        AppDialogs.showCustomDialog(
                          context: navigator.context, 
                          builder: CustomDialogWrapper(
                            borderColor: Colors.green.withValues(alpha: 0.4),
                            child: ConfirmShoppingTransferDialog(message: 'La compra \'$packName\' se ha añadido a tu historial.')
                          )
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
