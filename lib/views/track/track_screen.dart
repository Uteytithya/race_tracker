import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/views/track/stamp_screen.dart';
import 'dart:async';

import 'package:race_tracker/widget/navbar.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> with SingleTickerProviderStateMixin {
  // Current active tab
  int _activeTab = 0;

  // Selected segment
  String _selectedSegment = "Run"; // Default segment

  // Timer variables
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = "00:00";

  // Animation controller for stamp button
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // List to store timestamps (or time cards)
  List<String> _timestamps = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Start the timer function
  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        final duration = _stopwatch.elapsed;
        final minutes = duration.inMinutes.toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        _elapsedTime = "$minutes:$seconds";
      });
    });
  }

  // Reset timer function
  void _resetTimer() {
    _stopwatch.reset();
    setState(() {
      _elapsedTime = "00:00";
      _timestamps.clear();
    });
  }

  // Record timestamp WITHOUT a bib (direct timestamp)
  void _recordTimestamp() {
    // Animate button press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Record timestamp if timer is running
    if (_stopwatch.isRunning) {
      // Create a new Stamp object without bib
      Stamp stamp = Stamp(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        segment: _selectedSegment,
        time: DateTime.now(),
      );

      // Add the stamp to Firebase without associating with a participant
      Provider.of<StampProvider>(context, listen: false).addStamp(stamp);

      setState(() {
        _timestamps.add("$_selectedSegment - Time: $_elapsedTime");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Time recorded: $_selectedSegment - $_elapsedTime"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // If timer not running, start it
      _startTimer();
    }
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
                      'Tracker',
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
                  // Tab Selector and Segment Dropdown in a Row
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Tab Selector (now takes 70% of width)
                                                        Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      // Navigate to StampScreen instead of showing a local tab
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const StampScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Always white since it's now a navigation button
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Stamped',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        
                        // Small spacing between elements
                        const SizedBox(width: 8),
                        
                        // Segment Dropdown (takes 30% of width)
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedSegment,
                                icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4758E0)),
                                style: const TextStyle(
                                  color: Color(0xFF4758E0),
                                  fontWeight: FontWeight.bold,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedSegment = newValue;
                                    });
                                  }
                                },
                                dropdownColor: Colors.white,
                                items: <String>['Run', 'Cycle', 'Swim']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content based on selected tab
                  Expanded(
                    child: _activeTab == 0 ? _buildTrackerTab() : _buildStampedTab(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  // Tracker tab content with large center button
  Widget _buildTrackerTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer display
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: Text(
              _elapsedTime,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Selected segment display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            "Current: $_selectedSegment",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        
        const SizedBox(height: 50),
        
        // Large stamp button in center
        GestureDetector(
          onTap: _recordTimestamp,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _stopwatch.isRunning ? "STAMP" : "START",
                  style: const TextStyle(
                    color: Color(0xFF4758E0),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        
        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset button
            TextButton(
              onPressed: () {
                if (_stopwatch.isRunning) {
                  _stopwatch.stop();
                  _timer?.cancel();
                }
                _resetTimer();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Pause/Resume button
            TextButton(
              onPressed: () {
                if (_stopwatch.isRunning) {
                  _stopwatch.stop();
                  _timer?.cancel();
                } else if (_stopwatch.elapsed.inSeconds > 0) {
                  _startTimer();
                }
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _stopwatch.isRunning ? 'Pause' : 'Resume',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Stamped tab content
  Widget _buildStampedTab() {
    return Column(
      children: [
        // Header with title "Time stamped:"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'Time stamped:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Timestamp list
        Expanded(
          child: _timestamps.isEmpty
              ? const Center(
                  child: Text(
                    'No timestamps recorded yet',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: _timestamps.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key('timestamp_$index'),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        final removedTimestamp = _timestamps[index];
                        final removedIndex = index;
                        setState(() {
                          _timestamps.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Timestamp removed'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                setState(() {
                                  if (removedIndex < _timestamps.length) {
                                    _timestamps.insert(removedIndex, removedTimestamp);
                                  } else {
                                    _timestamps.add(removedTimestamp);
                                  }
                                });
                              },
                            ),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              _timestamps[index],
                              style: const TextStyle(
                                color: Color(0xFF4758E0),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}