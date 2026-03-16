import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddEditTicketItemDialog extends StatefulWidget {
  final TicketItem? item;
  const AddEditTicketItemDialog({super.key, this.item});

  @override
  State<AddEditTicketItemDialog> createState() => _AddEditTicketItemDialogState();
}

class _AddEditTicketItemDialogState extends State<AddEditTicketItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
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
    {'id': 'transporte', 'icon': Icons.directions_car_rounded, 'name': 'Transporte'},
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
          AppDialogs.dialogRowHeader(
            icon: widget.item == null ? Icons.receipt_long_rounded : Icons.edit_note_rounded, 
            title: widget.item == null ? 'Añadir Ticket' : 'Editar Ticket', 
            color: Colors.orange, 
            colorScheme: colorScheme
          ),
          SizedBox(height: 25.h),
          
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputTextWidget(
                    controller: _nameController,
                    label: 'Establecimiento',
                    hintText: 'Ej. Mercadona, Zara...',
                    enabled: !_isLoading,
                    errorText: _errorText,
                    onChanged: (value) {
                      if (_errorText != null && value.trim().isNotEmpty) {
                        setState(() => _errorText = null);
                      }
                    },
                  ),
                  SizedBox(height: 15.h),
                  
                  CustomInputTextWidget(
                    controller: _amountController,
                    label: 'Total ticket',
                    hintText: '0',
                    textInputType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !_isLoading,
                    autoFocus: false,
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('CATEGORÍA', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1))
                  ),
                  SizedBox(height: 10.h),
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
                                Text(cat['name'], style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
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
                  onPressed: () => Navigator.of(context).pop(), 
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'El establecimiento es obligatorio');
      return;
    }

    final amount = _humanizer.parse(_amountController.text);

    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    
    final newItem = TicketItem(
      id: widget.item?.id ?? const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      amount: amount,
      date: widget.item?.date ?? DateTime.now(),
      imagePath: widget.item?.imagePath,
      category: _selectedCategory,
      position: widget.item?.position ?? 0,
    );

    if (widget.item == null) {
      await context.read<TicketsCubit>().addItem(newItem);
    } else {
      await context.read<TicketsCubit>().updateItem(newItem);
    }
    
    if (mounted) Navigator.of(context).pop();
  }
}
