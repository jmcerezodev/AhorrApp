import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ShoppingEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  const ShoppingEmptyState({required this.colorScheme, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ajusta la columna al contenido
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset('assets/Logo.png', height: 60, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'LISTA VACÍA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'No tienes productos pendientes. ¡Añade lo que necesites para tu próxima compra!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
