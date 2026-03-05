import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
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

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4), 
              width: 1.5
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade400.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'PRECIOS REQUERIDOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Es obligatorio añadir el precio a todos los productos para poder incluirlos en tu lista de gastos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
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

    final boughtItems = shoppingCubit.state.items.where((item) => item.isBought).toList();
    final itemsWithoutPrice = boughtItems.where((item) => item.amount <= 0).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isFixingPrices ? Colors.red.shade400.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3),
            width: 1.5
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isFixingPrices ? Icons.warning_amber_rounded : (widget.onlyPrices ? Icons.list_alt_rounded : Icons.inventory_2_rounded), 
              color: _isFixingPrices ? Colors.red.shade400 : Colors.orange, 
              size: 40
            ),
            const SizedBox(height: 10),
            Text(
              _isFixingPrices ? 'FALTAN PRECIOS' : (widget.onlyPrices ? 'COMPLETAR PRECIOS' : 'CONFIGURAR PACK'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
            ),
            const SizedBox(height: 20),
            
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (_isFixingPrices) ...[
                      const Text(
                        'Añade el precio a los productos en la cesta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ...itemsWithoutPrice.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomInputTextWidget(
                          controller: _priceControllers[item.id]!,
                          label: item.name,
                          hintText: '0.00€',
                          textInputType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      )),
                    ] else if (!widget.onlyPrices) ...[
                      const Text(
                        'Indica un nombre para el pack de gastos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
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
                      const Text(
                        'Todos los productos tienen precio. ¿Quieres guardarlos individualmente?',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

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
                  child: ElevatedButton(
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
                            showDialog(
                              context: navigator.context, 
                              builder: (_) => const ConfirmShoppingTransferDialog(message: 'Los productos se han añadido individualmente.')
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
                          showDialog(
                            context: navigator.context, 
                            builder: (_) => ConfirmShoppingTransferDialog(message: 'La compra \'$packName\' se ha añadido a tu historial.')
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: FittedBox(
                      child: Text(
                        _isFixingPrices ? 'CONTINUAR' : 'GUARDAR',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
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
