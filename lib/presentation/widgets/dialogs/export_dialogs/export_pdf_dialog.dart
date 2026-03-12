import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/shared_preferences/preferences.dart';
import '../../../../data/local/local_db_service.dart';
import '../../../../data/services/pdf_export_service.dart';
import '../../../bloc/cubits.dart';

class ExportPdfDialog extends StatefulWidget {
  const ExportPdfDialog({super.key});

  @override
  State<ExportPdfDialog> createState() => _ExportPdfDialogState();
}

class _ExportPdfDialogState extends State<ExportPdfDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMovements = true;

  @override
  void initState() {
    super.initState();
    _checkMovements();
  }

  Future<void> _checkMovements() async {
    final movements = await getIt<LocalDbService>().getAllHistory();
    if (mounted) {
      setState(() {
        _hasMovements = movements.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    if (_passwordController.text != Preferences.password) {
      setState(() => _errorMessage = 'Contraseña incorrecta');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final movements = await getIt<LocalDbService>().getAllHistory();
      
      if (movements.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No hay datos para exportar';
        });
        return;
      }

      final double balanceValue = context.read<TotalMoneyCubit>().state.totalMoney;
      await getIt<PdfExportService>().exportFinancialReport(movements, balanceValue);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al generar el PDF';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryOrange = Theme.of(context).primaryColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDarkMode ? const Color(0xFF1A1C1E) : Colors.white,
      title: Column(
        children: [
          Icon(Icons.picture_as_pdf_rounded, color: primaryOrange, size: 40),
          const SizedBox(height: 10),
          const Text('Exportar Reporte', textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasMovements)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No hay movimientos registrados para exportar en este momento.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Para exportar tus datos financieros de forma segura, por favor introduce tu contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enabled: _hasMovements,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              errorText: _errorMessage,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: (_isLoading || !_hasMovements) ? null : _handleExport,
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Generar PDF'),
        ),
      ],
    );
  }
}
