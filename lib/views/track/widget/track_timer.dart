import 'package:flutter/material.dart';
import 'package:race_tracker/provider/race_provider.dart';

class TrackTimer extends StatelessWidget {
  const TrackTimer({
    super.key,
    required this.raceProvider,
  });

  final RaceProvider raceProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Race Time: ",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            raceProvider.elapsedTime,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  raceProvider.isRaceActive
                      ? Colors.green
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
