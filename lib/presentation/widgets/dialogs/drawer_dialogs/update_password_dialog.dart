import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';

class UpdatePasswordDialog extends StatelessWidget {
  final String title;
  final String text;
  
  const UpdatePasswordDialog({
    super.key, 
    required this.title, 
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView( // Añadido para evitar overflow con teclado
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.orange.shade100, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono y Título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_reset_rounded, color: Colors.orange.shade700, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueGrey,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
      
              // El widget interno ya maneja sus propios campos y botones
              const UpdatePasswordInputWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
