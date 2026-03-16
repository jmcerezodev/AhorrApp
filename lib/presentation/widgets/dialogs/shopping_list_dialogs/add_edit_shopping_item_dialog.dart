import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
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
  final _humanizer = HumanizeNumbers();

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
    
    _amountController = TextEditingController(
      text: widget.item == null || widget.item?.amount == 0 
        ? '' 
        : _humanizer.number(widget.item!.amount)
    );
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
      horizontalInsetPadding: 20.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con FittedBox para evitar overflows en títulos largos
          AppDialogs.dialogRowHeader(
            icon: widget.item == null ? Icons.add_shopping_cart_rounded : Icons.edit_note_rounded, 
            title: widget.item == null ? 'Añadir Producto' : 'Editar Producto', 
            color: Colors.orange, 
            colorScheme: colorScheme
          ),
          SizedBox(height: 20.h), // Reducido de 25 a 20 para ganar espacio
          
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              // Padding inferior dinámico para que el teclado no tape el último input
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 20.h : 0),
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
                  SizedBox(height: 12.h), // Reducido de 15 a 12
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end, // Cambiado a end para alinear con el label
                    children: [
                      // PRECIO: Con Expanded para proteger el ancho
                      Expanded(
                        flex: 3,
                        child: CustomInputTextWidget(
                          controller: _amountController,
                          label: 'Precio ud.',
                          hintText: '0',
                          textInputType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: !_isLoading,
                          autoFocus: false,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // CANTIDAD: Selector compacto
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('UDS.', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1))
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 50.h, // Reducido de 55 a 50
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.w),
                                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                    child: Icon(Icons.remove, size: 16.w, color: _quantity > 1 ? Colors.orange : Colors.grey.shade300),
                                  ),
                                  Text('$_quantity', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                                  GestureDetector(
                                    onTap: () => setState(() => _quantity++),
                                    child: Icon(Icons.add, size: 16.w, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 15.h), // Reducido de 20 a 15
                  
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('CATEGORÍA', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1))
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.w),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15.w),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'],
                            child: Row(
                              children: [
                                Icon(cat['icon'], size: 16.w, color: Colors.orange),
                                SizedBox(width: 10.w),
                                Flexible(
                                  child: Text(
                                    cat['name'], 
                                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                ),
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

          SizedBox(height: 25.h), // Reducido de 30 a 25
          
          OverflowBar(
            spacing: 12.w,
            overflowSpacing: 10.h,
            alignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 110.w, // Un poco más estrecho para asegurar que quepan
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(), 
                  colorScheme: colorScheme
                ),
              ),
              SizedBox(
                width: 110.w,
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

    final amount = _humanizer.parse(_amountController.text);

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
