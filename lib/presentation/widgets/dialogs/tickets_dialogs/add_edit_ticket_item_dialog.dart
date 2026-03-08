import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/presentation/bloc/tickets_cubit/tickets_cubit.dart';
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
    _amountController = TextEditingController(text: widget.item == null || widget.item?.amount == 0 ? '' : widget.item?.amount.toString());
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(widget.item == null ? Icons.receipt_long_rounded : Icons.edit_note_rounded, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 15),
                Text(
                  widget.item == null ? 'AÑADIR TICKET' : 'EDITAR TICKET',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 15),
                    
                    CustomInputTextWidget(
                      controller: _amountController,
                      label: 'Total ticket',
                      hintText: '0.00',
                      textInputType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !_isLoading,
                      autoFocus: false,
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                          value: _selectedCategory,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(15),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['id'],
                              child: Row(
                                children: [
                                  Icon(cat['icon'], size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(cat['name'], style: const TextStyle(fontSize: 13)),
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
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'El establecimiento es obligatorio');
      return;
    }

    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

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
