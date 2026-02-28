import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  
  const ErrorDialog({
    super.key, 
    this.errorMessage = 'Se A producido un error',
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

            const SizedBox(height: 10),

            const Icon(Icons.error_outline, color: Colors.red,size: 100,),

            const SizedBox(height: 10),

            Text(
              errorMessage, 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    
                    context.pop();
                    context.pop();
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
