import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEditRecurrentExpenseDialog extends StatefulWidget {
  final RecurrentExpense? expense;
  const AddEditRecurrentExpenseDialog({super.key, this.expense});

  @override
  State<AddEditRecurrentExpenseDialog> createState() => _AddEditRecurrentExpenseDialogState();
}

class _AddEditRecurrentExpenseDialogState extends State<AddEditRecurrentExpenseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late int _selectedDay;
  late bool _hasFixedDay;
  String _selectedCategory = 'general';
  bool _isLoading = false;
  late ScrollController _dayScrollController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'general', 'icon': Icons.receipt_long_rounded, 'name': 'General'},
    {'id': 'hogar', 'icon': Icons.home_work_rounded, 'name': 'Hogar'},
    {'id': 'suscripción', 'icon': Icons.subscriptions_rounded, 'name': 'Suscripción'},
    {'id': 'salud', 'icon': Icons.favorite_rounded, 'name': 'Salud'},
    {'id': 'transporte', 'icon': Icons.directions_car_rounded, 'name': 'Transporte'},
    {'id': 'ocio', 'icon': Icons.sports_esports_rounded, 'name': 'Ocio'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.expense?.name ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _hasFixedDay = widget.expense?.day != null;
    _selectedDay = widget.expense?.day ?? 1;
    _selectedCategory = widget.expense?.category ?? 'general';
    _dayScrollController = ScrollController(initialScrollOffset: (_selectedDay - 1) * 57.0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(widget.expense == null ? Icons.add_chart_rounded : Icons.edit_note_rounded, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.expense == null ? 'NUEVO GASTO FIJO' : 'EDITAR GASTO FIJO',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              CustomInputTextWidget(
                controller: _nameController,
                label: 'Nombre del gasto',
                hintText: 'Ej. Alquiler, Netflix...',
                enabled: !_isLoading,
                autoFocus: widget.expense == null,
              ),
              const SizedBox(height: 15),
              CustomInputTextWidget(
                controller: _amountController,
                label: 'Importe mensual',
                hintText: '0.00',
                enabled: !_isLoading,
                autoFocus: false,
                textInputType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 25),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Categoría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(20),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Row(
                          children: [
                            Icon(cat['icon'], size: 20, color: Colors.orange),
                            const SizedBox(width: 12),
                            Text(cat['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (val) => setState(() => _selectedCategory = val ?? 'general'),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cobro automático', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: _hasFixedDay, 
                      onChanged: _isLoading ? null : (val) => setState(() => _hasFixedDay = val),
                      activeColor: Colors.orange,
                    ),
                  ),
                ],
              ),

              if (_hasFixedDay) ...[
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Día de cobro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60, 
                  child: ListView.builder(
                    controller: _dayScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: 31,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isSelected = _selectedDay == day;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 45,
                          height: 45,
                          margin: const EdgeInsets.only(right: 12, bottom: 5, top: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: isSelected ? Colors.orange : colorScheme.onSurface.withValues(alpha: 0.03),
                            shape: CircleBorder(
                              side: BorderSide(
                                color: isSelected ? Colors.orange : colorScheme.onSurface.withValues(alpha: 0.15),
                                width: 1.5,
                              ),
                            ),
                            shadows: isSelected ? [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 35),
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
      ),
    );
  }

  void _save() async {
    final name = _nameController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText);

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, introduce un nombre y un importe válido')));
      return;
    }

    setState(() => _isLoading = true);
    await context.read<RecurrentExpensesCubit>().addOrUpdateExpense(
      id: widget.expense?.id,
      name: name,
      amount: amount,
      day: _hasFixedDay ? _selectedDay : null,
      category: _selectedCategory,
      isActive: widget.expense?.isActive ?? true,
    );
    if (mounted) context.pop();
  }
}
