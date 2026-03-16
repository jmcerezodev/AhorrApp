import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:flutter/material.dart';

class TicketsAppBar extends StatelessWidget {
  const TicketsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // IZQUIERDA: BOTÓN DRAWER
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: colorScheme.onSurface, size: 30.w),
            ),
          ),

          // DERECHA: INFO SECCIÓN
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TICKETS',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Digitaliza tus compras.',
                style: TextStyle(
                  fontSize: 11.sp,
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
