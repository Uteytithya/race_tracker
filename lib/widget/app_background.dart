import 'package:flutter/material.dart';


class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Header_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
