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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png',
              width: 150.w,
              height: 150.w,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
            SizedBox(height: 20.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.sp, // Escalamos el texto también
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
