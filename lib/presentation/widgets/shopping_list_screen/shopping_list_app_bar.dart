import 'package:flutter/material.dart';

class ShoppingListAppBar extends StatelessWidget {
  const ShoppingListAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IZQUIERDA: BOTÓN DRAWER
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface, size: 30),
            ),
          ),

          // DERECHA: INFO SECCIÓN (Solo Título y Subtítulo)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'LISTA DE LA COMPRA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const Text(
                'Tus ahorros empiezan aquí.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
