import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEditShoppingItemDialog extends StatefulWidget {
  final ShoppingListItem? item;
  const AddEditShoppingItemDialog({super.key, this.item});

  @override
  State<AddEditShoppingItemDialog> createState() => _AddEditShoppingItemDialogState();
}

class _AddEditShoppingItemDialogState extends State<AddEditShoppingItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late int _quantity;
  String _selectedCategory = 'general';
  bool _isLoading = false;
  String? _errorText;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'general', 'icon': Icons.shopping_basket_rounded, 'name': 'General'},
    {'id': 'alimentación', 'icon': Icons.restaurant_rounded, 'name': 'Comida'},
    {'id': 'limpieza', 'icon': Icons.cleaning_services_rounded, 'name': 'Limpieza'},
    {'id': 'higiene', 'icon': Icons.face_retouching_natural_rounded, 'name': 'Higiene'},
    {'id': 'hogar', 'icon': Icons.home_rounded, 'name': 'Hogar'},
    {'id': 'mascotas', 'icon': Icons.pets_rounded, 'name': 'Mascotas'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _amountController = TextEditingController(text: widget.item == null || widget.item?.amount == 0 ? '' : widget.item?.amount.toString());
    _selectedCategory = widget.item?.category ?? 'general';
    _quantity = widget.item?.quantity ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: widget.item == null ? Icons.add_shopping_cart_rounded : Icons.edit_note_rounded, 
            title: widget.item == null ? 'Añadir Producto' : 'Editar Producto', 
            color: Colors.orange, 
            colorScheme: colorScheme
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
                    controller: _nameController,
                    label: 'Nombre del producto',
                    hintText: 'Ej. Leche, Pan...',
                    enabled: !_isLoading,
                    errorText: _errorText,
                    onChanged: (value) {
                      if (_errorText != null && value.trim().isNotEmpty) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomInputTextWidget(
                          controller: _amountController,
                          label: 'Precio ud. (opcional)',
                          hintText: '0.00',
                          textInputType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: !_isLoading,
                          autoFocus: false,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UDS.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                            const SizedBox(height: 8),
                            Container(
                              height: 55,
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(Icons.remove, size: 16, color: _quantity > 1 ? Colors.orange : Colors.grey.shade300),
                                    ),
                                  ),
                                  Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                  InkWell(
                                    onTap: () => setState(() => _quantity++),
                                    borderRadius: BorderRadius.circular(10),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.add, size: 16, color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                        value: _selectedCategory,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'],
                            child: Row(
                              children: [
                                Icon(cat['icon'], size: 16, color: Colors.orange),
                                const SizedBox(width: 10),
                                Text(cat['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoading ? null : (val) => setState(() => _selectedCategory = val ?? 'general'),
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'El nombre es obligatorio');
      return;
    }

    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    
    if (widget.item == null) {
      await context.read<ShoppingListCubit>().addItem(name, amount: amount, category: _selectedCategory, quantity: _quantity);
    } else {
      final updatedItem = widget.item!.copyWith(
        name: name,
        amount: amount,
        category: _selectedCategory,
        quantity: _quantity,
      );
      await context.read<ShoppingListCubit>().updateItem(updatedItem);
    }
    
    if (mounted) context.pop();
  }
}
