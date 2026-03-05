import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class RecurrentEmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isFiltered;
  const RecurrentEmptyState({super.key, required this.colorScheme, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
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
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Text(
                isFiltered ? 'SIN RESULTADOS' : 'SIN GASTOS FIJOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeIn(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  isFiltered 
                    ? 'No hay gastos que coincidan con los filtros seleccionados.'
                    : 'Añade tus suscripciones o facturas mensuales para que la app las anote automáticamente por ti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
