import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/utils/enum.dart';
import 'dart:async';

import 'package:race_tracker/widget/navbar.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with SingleTickerProviderStateMixin {
  // Selected segment
  String _selectedSegment = "Run"; // Default segment

  // Animation controller for card press
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Currently animating BIB
  int? _animatingBib;

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load participants
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      // Race timer will be handled by RaceProvider, no need to start it here
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      await context.read<ParticipantProvider>().fetchParticipants();
      // Also fetch race data to get current timer state
      await context.read<RaceProvider>().fetchRaceData();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleAddStampForBib(int bib) async {
    final raceProvider = context.read<RaceProvider>();
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    // Find the participant by bib
    Participant? participant;
    try {
      participant = participantProvider.participants.firstWhere(
        (p) => p.bib == bib,
      );
    } catch (e) {
      debugPrint("Participant with bib $bib not found.");
      return;
    }

    // Check if a stamp for the current segment already exists
    final alreadyStamped = participant.stamps.any(
      (s) => s.segment.toLowerCase() == _selectedSegment.toLowerCase(),
    );

    if (alreadyStamped) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("BIB #$bib already has a $_selectedSegment stamp"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Animate the pressed BIB card
    setState(() => _animatingBib = bib);
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        setState(() => _animatingBib = null);
      });
    });

    // Start the race if not active
    if (!raceProvider.isRaceActive) {
      await raceProvider.startRace();
    }

    // Create and add the stamp
    Stamp stamp = Stamp(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      segment: _selectedSegment,
      time: DateTime.now(),
      bib: bib,
    );
    await stampProvider.addStampToParticipant(
      stamp,
      bib,
    ); // Convert bib to String
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$_selectedSegment stamp recorded for BIB #$bib"),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleRemoveStampForBib(Stamp stamp, int bib) async {
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    // Find the participant by bib
    Participant? participant;
    try {
      participant = participantProvider.participants.firstWhere(
        (p) => p.bib == bib,
      );
    } catch (e) {
      debugPrint("Participant with bib $bib not found.");
      return;
    }

    // Find the stamp for the selected segment
    Stamp? stampToRemove;
    try {
      stampToRemove = participant.stamps.firstWhere(
        (s) => s.segment.toLowerCase() == _selectedSegment.toLowerCase(),
      );

      if (stampToRemove == null) {
        throw Exception("No matching stamp found");
      }
    } catch (_) {
      Logger().i("No $_selectedSegment stamp found for BIB #$bib");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No $_selectedSegment stamp to remove for BIB #$bib"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Animate the pressed BIB card
    setState(() => _animatingBib = bib);
    _animationController.forward().then((_) {
      _animationController.reverse().then((_) {
        setState(() => _animatingBib = null);
      });
    });

    // Remove the stamp
    try {
      await stampProvider.removeStampFromParticipant(
        stampToRemove,
        bib, // Convert bib to String
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$_selectedSegment stamp removed for BIB #$bib"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove stamp for BIB #$bib"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Only animation controller needs to be disposed
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participants = context.watch<ParticipantProvider>().participants;
    final raceProvider =
        context.watch<RaceProvider>(); // Get race provider for timer

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
                  // Navigation bar with tabs
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        // Tracker tab (active)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4758E0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                'Tracker',
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

                  // Timer display - using global timer from RaceProvider
                  Container(
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
                  ),

                  // Segment Sub-Tabs
                  _buildSegmentTabs(),

                  // BIB Grid Content
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : participants.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'No participants found',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _fetchData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF4758E0),
                                    ),
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            )
                            : _buildBibGrid(participants),
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

  Widget _buildSegmentTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          for (final segment in ['Run', 'Cycle', 'Swim'])
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSegment = segment;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        _selectedSegment == segment
                            ? Colors.white
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      segment,
                      style: TextStyle(
                        color:
                            _selectedSegment == segment
                                ? const Color(0xFF4758E0)
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBibGrid(List<Participant> participants) {
    // Get active participants (not finished)
    final activeParticipants =
        participants
            .where((p) => p.status != ParticipantStatus.finished)
            .toList();

    if (activeParticipants.isEmpty) {
      return const Center(
        child: Text(
          'No active participants to track',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: activeParticipants.length,
        itemBuilder: (context, index) {
          final participant = activeParticipants[index];
          final bool isAnimating = _animatingBib == participant.bib;

          // Inside _buildBibGrid
          return GestureDetector(
            onTap: () => _handleAddStampForBib(participant.bib),
            onLongPress:
                () => _handleRemoveStampForBib(
                  participant.stamps.firstWhere(
                    (s) =>
                        s.segment.toLowerCase() ==
                        _selectedSegment.toLowerCase(),
                  ),
                  participant.bib,
                ),
            child: AnimatedScale(
              scale: isAnimating ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${participant.bib}',
                      style: const TextStyle(
                        color: Color(0xFF4758E0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      participant.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4758E0),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      _getIconForSegment(_selectedSegment),
                      color: const Color(0xFF4758E0),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForSegment(String segment) {
    switch (segment.toLowerCase()) {
      case 'run':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
      case 'swim':
        return Icons.pool;
      default:
        return Icons.timer;
    }
  }
}
