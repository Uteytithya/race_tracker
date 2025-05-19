import 'package:flutter/material.dart';

class ResultTimer extends StatelessWidget {
  const ResultTimer({super.key, required this.elapsedTime});

  final String elapsedTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        'Race Time: $elapsedTime',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
