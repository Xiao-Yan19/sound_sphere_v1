
import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Go to Home',
      onPressed: onPressed,
      icon: const Icon(
        Icons.home_rounded,
        color: Color(0xFF64E6C2),
        size: 26,
      ),
    );
  }
}
