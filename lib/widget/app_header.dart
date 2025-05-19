import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {

  final String title;
  final Widget? leading;

  const AppHeader({
    super.key,
    required this.title,
    this.leading, 
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 20,
      child: Row(
        children: [
          if (leading != null) leading!,
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
