import 'package:flutter/material.dart';

class RecurrentAppBar extends StatelessWidget {
  const RecurrentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MIS PAGOS FIJOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Planifica tus gastos mensuales',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          // ICONO DE SECCIÓN (Antes era el botón de añadir)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 1.5)
            ),
            child: const Icon(Icons.repeat_rounded, color: Colors.orange, size: 24),
          ),
        ],
      ),
    );
  }
}
