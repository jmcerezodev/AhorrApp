import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddEditRecurrentExpenseDialog extends StatefulWidget {
  final RecurrentExpense? expense;
  final bool isIncome;

  const AddEditRecurrentExpenseDialog({
    super.key, 
    this.expense,
    required this.isIncome,
  });

  @override
  State<AddEditRecurrentExpenseDialog> createState() => _AddEditRecurrentExpenseDialogState();
}

class _AddEditRecurrentExpenseDialogState extends State<AddEditRecurrentExpenseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late bool _hasFixedDay;
  late bool _includeInSummary;
  late RecurrentFrequency _selectedFrequency;
  late DateTime _selectedStartDate;
  String _selectedCategory = 'general';
  bool _isLoading = false;

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
    _includeInSummary = widget.expense?.includeInSummary ?? true;
    _selectedCategory = widget.expense?.category ?? 'general';
    _selectedFrequency = widget.expense?.frequency ?? RecurrentFrequency.monthly;
    _selectedStartDate = widget.expense?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
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
            icon: widget.expense == null 
              ? (widget.isIncome ? Icons.add_circle_outline_rounded : Icons.add_chart_rounded)
              : Icons.edit_note_rounded,
            title: widget.expense == null 
              ? (widget.isIncome ? 'NUEVO INGRESO FIJO' : 'NUEVO GASTO FIJO') 
              : (widget.isIncome ? 'EDITAR INGRESO FIJO' : 'EDITAR GASTO FIJO'),
            color: Colors.orange,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 25),
          CustomInputTextWidget(
            controller: _nameController,
            label: 'Nombre del registro',
            hintText: widget.isIncome ? 'Ej. Nómina, Alquiler...' : 'Ej. Alquiler, Netflix...',
            enabled: !_isLoading,
            autoFocus: false,
          ),
          const SizedBox(height: 15),
          CustomInputTextWidget(
            controller: _amountController,
            label: 'Importe',
            hintText: '0.00',
            enabled: !_isLoading,
            autoFocus: false,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 25),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
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
                                  Flexible(child: Text(cat['name'], style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
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
              const SizedBox(width: 15),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Automático', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    const SizedBox(height: 5),
                    Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: _hasFixedDay, 
                        onChanged: _isLoading ? null : (val) {
                          setState(() {
                            _hasFixedDay = val;
                            if (val) _includeInSummary = true;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: !_hasFixedDay 
              ? Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.analytics_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Incluir en el resumen mensual',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Checkbox(
                            value: _includeInSummary, 
                            activeColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            onChanged: _isLoading ? null : (val) => setState(() => _includeInSummary = val ?? true),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: _hasFixedDay 
                ? Column(
                    key: const ValueKey('automatic_settings'),
                    children: [
                      const SizedBox(height: 25),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 20),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Configuración del Ciclo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5))),
                      ),
                      const SizedBox(height: 15),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Frecuencia', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<RecurrentFrequency>(
                                      value: _selectedFrequency,
                                      isExpanded: true,
                                      borderRadius: BorderRadius.circular(15),
                                      items: const [
                                        DropdownMenuItem(value: RecurrentFrequency.monthly, child: Text('Mensual', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: RecurrentFrequency.quarterly, child: Text('Trimestral', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: RecurrentFrequency.semiAnnually, child: Text('Semestral', style: TextStyle(fontSize: 13))),
                                        DropdownMenuItem(value: RecurrentFrequency.annually, child: Text('Anual', style: TextStyle(fontSize: 13))),
                                      ],
                                      onChanged: _isLoading ? null : (val) => setState(() => _selectedFrequency = val!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Fecha de cobro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _isLoading ? null : () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            DateFormat('dd/MM/yy').format(_selectedStartDate),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_month_rounded, color: Colors.orange, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),

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
                child: AppDialogs.dialogPrimaryButton(
                  text: 'GUARDAR',
                  color: Colors.orange,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _save,
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
      day: _hasFixedDay ? _selectedStartDate.day : null,
      category: _selectedCategory,
      isActive: widget.expense?.isActive ?? true,
      frequency: _selectedFrequency,
      startDate: _selectedStartDate,
      includeInSummary: _includeInSummary,
      isIncome: widget.isIncome,
    );
    if (mounted) context.pop();
  }
}
