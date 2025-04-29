// bottom_navigation_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF2A3182), // More accurate color match to the image
      height: 56, // Standard height for bottom navigation
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              // Handle home navigation
            },
            color: Colors.white,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              // Handle clock/history navigation
            },
            color: Colors.white,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Handle menu navigation
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
