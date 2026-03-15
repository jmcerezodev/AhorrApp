import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:flutter/material.dart';

class EmptyListWidget extends StatelessWidget {
  final String text;

  const EmptyListWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    // Detectamos si es pantalla pequeña para ajustar el logo base
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png',
              // Reducimos el tamaño base en pantallas pequeñas (de 150 a 100)
              width: (isSmallScreen ? 100 : 150).w,
              height: (isSmallScreen ? 100 : 150).w,
              opacity: const AlwaysStoppedAnimation(0.3), // Más sutil
            ),
            SizedBox(height: 20.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                    fontSize: (isSmallScreen ? 13 : 15).sp, // Texto más contenido
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
