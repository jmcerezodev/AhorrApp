import 'package:ahorrapp/core/config/responsive_utils.dart';
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
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset('assets/Logo.png', height: 60.h, fit: BoxFit.contain),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Text(
                isFiltered ? 'SIN RESULTADOS' : 'SIN GASTOS FIJOS',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            FadeIn(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: Text(
                  isFiltered 
                    ? 'No hay gastos que coincidan con los filtros seleccionados.'
                    : 'Añade tus suscripciones o facturas mensuales para que la app las anote automáticamente por ti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
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
