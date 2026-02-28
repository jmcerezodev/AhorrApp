import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiometricInfoDialog extends StatelessWidget {
  const BiometricInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fingerprint_rounded, color: Colors.orange.shade700, size: 32),
            ),
            const SizedBox(height: 20),
            const Text(
              'SEGURIDAD BIOMÉTRICA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.blueGrey,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Al activar esta opción, utilizaremos la seguridad de tu dispositivo (huella o rostro) para proteger el acceso a tus datos financieros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(false),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('ACTIVAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
