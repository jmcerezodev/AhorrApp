import 'package:flutter/material.dart';

class SwipeBackgroundWidget extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const SwipeBackgroundWidget({
    super.key,
    required this.color, 
    required this.icon, 
    required this.label,
    required this.alignment
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8), 
        borderRadius: BorderRadius.circular(20)
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          ],
          if (!isLeft) ...[
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ],
      ),
    );
  }
}
