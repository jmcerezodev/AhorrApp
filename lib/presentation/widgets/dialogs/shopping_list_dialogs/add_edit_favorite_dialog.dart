import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEditFavoriteDialog extends StatefulWidget {
  final ShoppingTemplate? favorite;
  final bool focusPrice; 
  
  const AddEditFavoriteDialog({
    super.key, 
    this.favorite,
    this.focusPrice = false,
  });

  @override
  State<AddEditFavoriteDialog> createState() => _AddEditFavoriteDialogState();
}

class _AddEditFavoriteDialogState extends State<AddEditFavoriteDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String _selectedCategory = 'general';
  bool _isLoading = false;

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
    final firstItem = widget.favorite?.items.firstOrNull;
    _nameController = TextEditingController(text: widget.favorite?.name ?? '');
    _amountController = TextEditingController(text: firstItem == null || firstItem.amount == 0 ? '' : firstItem.amount.toString());
    _selectedCategory = firstItem?.category ?? 'general';
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
                  child: const Icon(Icons.stars_rounded, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 15),
                Text(
                  widget.favorite == null ? 'NUEVO FAVORITO' : 'EDITAR FAVORITO',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ],
            ),
            const SizedBox(height: 25),
            CustomInputTextWidget(
              controller: _nameController,
              label: 'Nombre del producto',
              hintText: 'Ej. Leche, Pan...',
              enabled: !_isLoading,
              autoFocus: !widget.focusPrice, // FOCO DINÁMICO
            ),
            const SizedBox(height: 15),
            CustomInputTextWidget(
              controller: _amountController,
              label: 'Importe habitual',
              hintText: '0.00',
              textInputType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !_isLoading,
              autoFocus: widget.focusPrice, // FOCO DINÁMICO
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

            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
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
    if (name.isEmpty) return;

    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    setState(() => _isLoading = true);
    
    await context.read<ShoppingTemplatesCubit>().updateOrSaveFavorite(
      id: widget.favorite?.id,
      name: name,
      amount: amount,
      category: _selectedCategory,
    );
    
    if (mounted) context.pop();
  }
}
