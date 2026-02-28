import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordDialog extends StatelessWidget {

  final String errorTitle;
  final String errorText;
  
  const ResetPasswordDialog({
    super.key, 
    required this.errorTitle, 
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorTitle,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorText, 
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    context.push('/login');
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}