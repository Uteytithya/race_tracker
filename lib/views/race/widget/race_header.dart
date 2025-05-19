import 'package:flutter/material.dart';
class RaceHeader extends StatelessWidget {
  const RaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        Row(
          children: [
            Container(
              width: 300,
              margin: const EdgeInsets.only(left: 20),
              child: const Text(
                'Race',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}