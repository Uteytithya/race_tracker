import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF2A3182),
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            color: Colors.white,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.flag),
            onPressed: () {
              Navigator.pushNamed(context, '/race');
            },
            color: Colors.white,
          ),
          const SizedBox(width: 40),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              Navigator.pushNamed(context, '/track');
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
