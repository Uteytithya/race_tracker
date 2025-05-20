import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/provider/race_provider.dart';

class RaceContent extends StatelessWidget {
  const RaceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RaceProvider>(
      builder: (context, raceProvider, child) {
        final int participantsLeft = raceProvider.participantsLeft;
        final bool isRaceActive = raceProvider.isRaceActive;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Participant Left',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$participantsLeft',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Race Timer
            Text(
              'Race Time: ${raceProvider.elapsedTime}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Start button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
              child: ElevatedButton(
                onPressed:
                    !isRaceActive
                        ? () {
                          raceProvider.startRace();
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF344BD0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                   'Start',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Finish button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
              child: ElevatedButton(
                onPressed:
                    !isRaceActive
                        ? null
                        : () {
                          raceProvider.finishRace();
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF344BD0), // Darker blue
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Finish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Reset button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
              child: OutlinedButton(
                onPressed:
                    isRaceActive
                        ? null
                        : () {
                          raceProvider.resetRace();
                        },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
