import 'package:flutter/material.dart';

class PrivacyAmountText extends StatelessWidget {
  final String amount;
  final TextStyle style;
  final bool isPrivacyActive;

  const PrivacyAmountText({
    super.key,
    required this.amount,
    required this.style,
    required this.isPrivacyActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Text(
        amount,
        key: ValueKey<String>(amount),
        style: style,
      ),
    );
  }
}
