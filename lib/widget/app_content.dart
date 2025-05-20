import 'package:flutter/material.dart';
class AppContent extends StatelessWidget {

  final Widget content;
  final Widget? tabBar;
  const AppContent({
    super.key,
    required this.content,
    this.tabBar,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xFF4758E0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (tabBar != null) tabBar!,
            // Race AppContent
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
