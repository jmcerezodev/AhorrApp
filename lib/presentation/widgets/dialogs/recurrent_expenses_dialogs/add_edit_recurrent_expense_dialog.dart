import 'package:ahorrapp/core/config/responsive_utils.dart';
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
    // REGLA DE ORO: Si editamos, mostramos el valor sin decimales si es entero
    final initialAmount = widget.expense?.amount;
    _amountController = TextEditingController(
      text: initialAmount != null ? initialAmount.toInt().toString() : ''
    );
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
      horizontalInsetPadding: 20.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: widget.expense == null 
              ? (widget.isIncome ? Icons.add_circle_outline_rounded : Icons.add_chart_rounded)
              : Icons.edit_note_rounded,
            title: widget.expense == null 
              ? (widget.isIncome ? 'Nuevo Ingreso Fijo' : 'Nuevo Gasto Fijo') 
              : (widget.isIncome ? 'Editar Ingreso Fijo' : 'Editar Gasto Fijo'),
            color: Colors.orange,
            colorScheme: colorScheme,
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
                    label: 'NOMBRE DEL REGISTRO',
                    hintText: widget.isIncome ? 'Ej. Nómina, Alquiler...' : 'Ej. Alquiler, Netflix...',
                    enabled: !_isLoading,
                    autoFocus: false,
                  ),
                  SizedBox(height: 15.h),
                  CustomInputTextWidget(
                    controller: _amountController,
                    label: 'IMPORTE',
                    hintText: '0',
                    enabled: !_isLoading,
                    autoFocus: false,
                    textInputType: const TextInputType.numberWithOptions(decimal: false),
                  ),
                  SizedBox(height: 25.h),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CATEGORÍA', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
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
                                          SizedBox(width: 8.w),
                                          Flexible(child: Text(cat['name'], style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
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
                      SizedBox(width: 15.w),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('AUTOMÁTICO', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                            SizedBox(height: 8.h),
                            Transform.scale(
                              scale: 0.7,
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
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(15.w),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _includeInSummary, 
                                    activeColor: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.w)),
                                    onChanged: _isLoading ? null : (val) => setState(() => _includeInSummary = val ?? true),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Incluir en el resumen mensual',
                                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                                    ),
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
                    child: _hasFixedDay 
                      ? Column(
                          children: [
                            SizedBox(height: 25.h),
                            const Divider(height: 1, thickness: 0.5),
                            SizedBox(height: 20.h),
                            
                            Text('CONFIGURACIÓN DEL CICLO', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                            SizedBox(height: 15.h),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('FRECUENCIA', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                                      SizedBox(height: 8.h),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.w),
                                          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<RecurrentFrequency>(
                                            value: _selectedFrequency,
                                            isExpanded: true,
                                            borderRadius: BorderRadius.circular(15.w),
                                            items: [
                                              DropdownMenuItem(value: RecurrentFrequency.monthly, child: Text('Mensual', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
                                              DropdownMenuItem(value: RecurrentFrequency.quarterly, child: Text('Trimestral', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
                                              DropdownMenuItem(value: RecurrentFrequency.semiAnnually, child: Text('Semestral', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
                                              DropdownMenuItem(value: RecurrentFrequency.annually, child: Text('Anual', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600))),
                                            ],
                                            onChanged: _isLoading ? null : (val) => setState(() => _selectedFrequency = val!),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 15.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('FECHA COBRO', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                                      SizedBox(height: 8.h),
                                      GestureDetector(
                                        onTap: _isLoading ? null : () => _selectDate(context),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15.w),
                                            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  DateFormat('dd/MM/yy').format(_selectedStartDate),
                                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(Icons.calendar_month_rounded, color: Colors.orange, size: 16.w),
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
                      : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 35.h),
          Row(
            children: [
              Expanded(
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(), 
                  colorScheme: colorScheme
                ),
              ),
              SizedBox(width: 15.w),
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
      amount: amount.toInt().toDouble(), // Forzamos entero para consistencia
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
