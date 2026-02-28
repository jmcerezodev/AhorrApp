import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessfulDialogNoGo extends StatelessWidget {

  final String sucessfulName;
  
  const SuccessfulDialogNoGo({
    super.key, 
    required this.sucessfulName,
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

            const Icon(Icons.check_circle, color: Colors.green,size: 100,),

            const SizedBox(height: 10),

            Text(
              sucessfulName, 
              textAlign: TextAlign.center,
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
