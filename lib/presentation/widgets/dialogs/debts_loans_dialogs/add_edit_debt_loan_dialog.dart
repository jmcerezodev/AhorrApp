import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AddEditDebtLoanDialog extends StatefulWidget {
  final DebtLoan? item;
  final DebtLoanType initialType;

  const AddEditDebtLoanDialog({
    super.key, 
    this.item, 
    required this.initialType
  });

  @override
  State<AddEditDebtLoanDialog> createState() => _AddEditDebtLoanDialogState();
}

class _AddEditDebtLoanDialogState extends State<AddEditDebtLoanDialog> {
  late TextEditingController _nameController;
  late TextEditingController _personController;
  late TextEditingController _amountController;
  late TextEditingController _installmentAmountController;
  late TextEditingController _monthsController;
  late FocusNode _monthsFocusNode;
  
  late DateTime? _selectedDate;
  late DateTime? _dueDate;
  late DebtLoanType _type;
  
  bool _isInstallment = false;
  bool _isAutoCalculate = true;
  bool _addToHistory = false;
  bool _isLoading = false;

  String? _nameError;
  String? _personError;
  String? _amountError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _type = widget.item?.type ?? widget.initialType;
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _personController = TextEditingController(text: widget.item?.person ?? '');
    _amountController = TextEditingController(text: widget.item?.totalAmount.toString() ?? '');
    _installmentAmountController = TextEditingController(text: widget.item?.installmentAmount?.toString() ?? '');
    _monthsController = TextEditingController(text: widget.item?.totalInstallments?.toString() ?? '');
    _monthsFocusNode = FocusNode();
    
    _selectedDate = widget.item?.date;
    _dueDate = widget.item?.dueDate;
    _isInstallment = widget.item?.isInstallment ?? false;

    _amountController.addListener(_onAmountOrMonthsChanged);
    _monthsController.addListener(_onAmountOrMonthsChanged);
    _monthsController.addListener(_onMonthsChangedUpdateDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _personController.dispose();
    _amountController.dispose();
    _installmentAmountController.dispose();
    _monthsController.dispose();
    _monthsFocusNode.dispose();
    super.dispose();
  }

  double _parseInput(String input) {
    String sanitized = input.trim().replaceAll(' ', '').replaceAll('\u00A0', '');
    if (sanitized.isEmpty) return 0;

    if (sanitized.contains('.') && sanitized.contains(',')) {
      int dotIndex = sanitized.lastIndexOf('.');
      int commaIndex = sanitized.lastIndexOf(',');
      if (dotIndex > commaIndex) {
        sanitized = sanitized.replaceAll(',', '');
      } else {
        sanitized = sanitized.replaceAll('.', '').replaceAll(',', '.');
      }
    } else if (sanitized.contains(',')) {
      sanitized = sanitized.replaceAll(',', '.');
    } else if (sanitized.contains('.')) {
      final parts = sanitized.split('.');
      if (parts.length > 2) {
        sanitized = sanitized.replaceAll('.', '');
      } else if (parts.length == 2 && parts[1].length == 3) {
        sanitized = sanitized.replaceAll('.', '');
      }
    }

    return double.tryParse(sanitized) ?? 0;
  }

  void _onAmountOrMonthsChanged() {
    if (_isAutoCalculate && _isInstallment) {
      final total = _parseInput(_amountController.text);
      final months = int.tryParse(_monthsController.text.trim()) ?? 0;
      if (total > 0 && months > 0) {
        final result = total / months;
        _installmentAmountController.text = result.toStringAsFixed(2);
      } else {
        _installmentAmountController.clear();
      }
    }
  }

  void _onMonthsChangedUpdateDate() {
    if (_isInstallment && _monthsFocusNode.hasFocus) {
      final text = _monthsController.text.trim();
      if (text.isEmpty) { setState(() => _dueDate = null); return; }
      final months = int.tryParse(text) ?? 0;
      if (months > 0) {
        setState(() {
          final startDate = _selectedDate ?? DateTime.now();
          _dueDate = DateTime(startDate.year, startDate.month + months, startDate.day);
        });
      }
    }
  }

  void _calculateMonthsFromDates() {
    if (_selectedDate != null && _dueDate != null) {
      final difference = _dueDate!.difference(_selectedDate!);
      final months = (difference.inDays / 30).round();
      if (months > 0) {
        _monthsController.removeListener(_onMonthsChangedUpdateDate);
        _monthsController.text = months.toString();
        _monthsController.addListener(_onMonthsChangedUpdateDate);
        _onAmountOrMonthsChanged();
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now()) : (_selectedDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) { _dueDate = picked; _dateError = null; } 
        else { _selectedDate = picked; }
        _calculateMonthsFromDates();
      });
    }
  }

  double _calculateInitialPaidAmount() {
    if (!_isInstallment || _selectedDate == null) return 0.0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate!.isAfter(today)) return 0.0;
    int monthsPassed = (today.year - _selectedDate!.year) * 12 + (today.month - _selectedDate!.month);
    if (today.day >= _selectedDate!.day) monthsPassed += 1;
    final installment = _parseInput(_installmentAmountController.text);
    final total = _parseInput(_amountController.text);
    double calculatedPaid = monthsPassed * installment;
    return calculatedPaid > total ? total : calculatedPaid;
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
            icon: _type == DebtLoanType.debt ? Icons.money_off_rounded : Icons.handshake_rounded,
            title: widget.item == null 
              ? (_type == DebtLoanType.debt ? 'Nueva Deuda' : 'Nuevo Préstamo')
              : (_type == DebtLoanType.debt ? 'Editar Deuda' : 'Editar Préstamo'),
            color: Colors.orange,
            colorScheme: colorScheme,
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
                    label: 'CONCEPTO',
                    hintText: 'Ej. Préstamo coche, Cena...',
                    errorText: _nameError,
                    enabled: !_isLoading,
                    onChanged: (val) { if (_nameError != null) setState(() => _nameError = null); },
                  ),
                  const SizedBox(height: 15),
                  
                  CustomInputTextWidget(
                    controller: _personController,
                    label: _type == DebtLoanType.debt ? '¿A QUIÉN LE DEBES?' : '¿QUIÉN TE DEBE?',
                    hintText: 'Nombre de la persona',
                    errorText: _personError,
                    enabled: !_isLoading,
                    onChanged: (val) { if (_personError != null) setState(() => _personError = null); },
                  ),
                  const SizedBox(height: 15),

                  CustomInputTextWidget(
                    controller: _amountController,
                    label: 'IMPORTE TOTAL',
                    hintText: '0.00',
                    errorText: _amountError,
                    enabled: !_isLoading,
                    textInputType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) { 
                      if (_amountError != null) setState(() => _amountError = null);
                      _onAmountOrMonthsChanged();
                    },
                  ),
                  const SizedBox(height: 25),

                  _buildInstallmentToggle(colorScheme),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _isInstallment 
                      ? Column(
                          children: [
                            const SizedBox(height: 25),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDatePicker(
                                    label: 'FECHA INICIO',
                                    date: _selectedDate,
                                    onTap: () => _selectDate(context, false),
                                    isOptional: true,
                                    onClear: () => setState(() => _selectedDate = null),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _buildDatePicker(
                                    label: 'VENCIMIENTO',
                                    date: _dueDate,
                                    errorText: _dateError,
                                    onTap: () => _selectDate(context, true),
                                    isOptional: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomInputTextWidget(
                                    controller: _monthsController,
                                    focusNode: _monthsFocusNode,
                                    label: 'MESES',
                                    hintText: 'Ej. 12',
                                    textInputType: TextInputType.number,
                                    enabled: !_isLoading,
                                    onChanged: (val) {
                                      _onAmountOrMonthsChanged();
                                      _onMonthsChangedUpdateDate();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: CustomInputTextWidget(
                                    controller: _installmentAmountController,
                                    label: 'CUOTA MENSUAL',
                                    hintText: '0.00',
                                    textInputType: const TextInputType.numberWithOptions(decimal: true),
                                    enabled: !_isLoading && !_isAutoCalculate,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _isAutoCalculate, 
                                    onChanged: (val) => setState(() {
                                      _isAutoCalculate = val ?? true;
                                      if (_isAutoCalculate) _onAmountOrMonthsChanged();
                                    }),
                                    activeColor: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  ),
                                  const Text(
                                    'Calcular cuota automáticamente',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Column(
                            children: [
                              _buildDatePicker(
                                label: 'FECHA LÍMITE (OPCIONAL)',
                                date: _dueDate,
                                onTap: () => _selectDate(context, true),
                                isOptional: true,
                                onClear: () => setState(() => _dueDate = null),
                              ),
                              const SizedBox(height: 15),
                              if (widget.item == null) 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _addToHistory, 
                                        onChanged: (val) => setState(() => _addToHistory = val ?? false),
                                        activeColor: Colors.orange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      ),
                                      const Expanded(
                                        child: Text(
                                          'Registrar movimiento inicial en el historial',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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
                  colorScheme: colorScheme,
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

  Widget _buildDatePicker({
    required String label, 
    DateTime? date, 
    required VoidCallback onTap,
    bool isOptional = false,
    VoidCallback? onClear,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: errorText != null ? Colors.red.shade800 : Colors.grey.shade300, width: errorText != null ? 1.5 : 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    date != null ? DateFormat('dd/MM/yy').format(date) : 'Seleccionar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: date == null ? Colors.grey : null),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isOptional && date != null)
                  GestureDetector(onTap: onClear, child: const Icon(Icons.close_rounded, size: 14, color: Colors.red))
                else
                  const Icon(Icons.calendar_month_rounded, color: Colors.orange, size: 16),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(errorText, style: TextStyle(color: Colors.red.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildInstallmentToggle(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pago a Plazos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                Text('Dividir el total en cuotas mensuales', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: _isInstallment, 
              onChanged: (val) {
                setState(() {
                  _isInstallment = val;
                  if (val && _selectedDate == null) _selectedDate = DateTime.now();
                  if (val) Future.delayed(const Duration(milliseconds: 10), () { _onMonthsChangedUpdateDate(); _onAmountOrMonthsChanged(); });
                });
              },
              activeColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _save() async {
    bool hasError = false;
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Campo obligatorio' : null;
      _personError = _personController.text.trim().isEmpty ? 'Campo obligatorio' : null;
      final amount = _parseInput(_amountController.text);
      if (amount <= 0) _amountError = 'Importe no válido'; else _amountError = null;
      if (_isInstallment && _dueDate == null) _dateError = 'Campo obligatorio'; else _dateError = null;
      if (_nameError != null || _personError != null || _amountError != null || _dateError != null) hasError = true;
    });
    if (hasError) return;
    setState(() => _isLoading = true);
    final installmentAmount = _parseInput(_installmentAmountController.text);
    final totalInstallments = int.tryParse(_monthsController.text.trim());
    final finalStartDate = _selectedDate ?? DateTime.now();
    final double initialPaid = _calculateInitialPaidAmount();
    
    await context.read<DebtsLoansCubit>().addOrUpdateDebtLoan(
      id: widget.item?.id,
      name: _nameController.text.trim(),
      person: _personController.text.trim(),
      totalAmount: _parseInput(_amountController.text),
      paidAmount: initialPaid,
      type: _type,
      date: finalStartDate,
      dueDate: _dueDate,
      isInstallment: _isInstallment,
      totalInstallments: totalInstallments,
      installmentAmount: installmentAmount,
      addToRecurrent: _isInstallment,
      existingRecurrentId: widget.item?.recurrentExpenseId,
      addToHistory: _addToHistory, // PASAMOS EL NUEVO FLAG
    );
    if (mounted) context.pop();
  }
}
