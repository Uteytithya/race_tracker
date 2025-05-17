import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/widget/navbar.dart';
import 'package:race_tracker/provider/race_provider.dart'; // You'll need to create this

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  int _activeTabIndex = 1; // Since this is the "Race" tab

  @override
  void initState() {
    super.initState();
    // Fetch race data in the ResultScreen
    Provider.of<RaceProvider>(context, listen: false).fetchRaceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(color: Colors.black.withOpacity(0.2)),
          // Header
          Column(
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
          ),
          // Main Content
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4758E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Tab Selector
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Return to StampScreen
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    _activeTabIndex == 0
                                        ? const Color(0xFF4758E0)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  'Un-Bibbed',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  _activeTabIndex == 1
                                      ? const Color(0xFF4758E0)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Race',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Race status tabs
                  // Race status tabs
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F51B5), // Slightly darker blue
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // This is already the Status tab, so no navigation needed
                              setState(() {
                                // We could add a local status/result tab state if needed
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          color: Colors.white24,
                          thickness: 1,
                          width: 1,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to ResultScreen when Result tab is clicked
                              Navigator.pushNamed(context, '/result');
                              // Alternatively use:
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const ResultScreen(),
                              //   ),
                              // );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Result',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Race content
                  Expanded(child: _buildRaceContent()),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildRaceContent() {
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
                    isRaceActive
                        ? null
                        : () {
                          raceProvider.startRace();
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
                  'Start',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
