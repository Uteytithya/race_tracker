import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/views/track/widget/track_content.dart';
import 'package:race_tracker/views/track/widget/track_timer.dart';
import 'package:race_tracker/widget/app_background.dart';
import 'dart:async';
import 'package:race_tracker/widget/app_bottom_navbar.dart';
import 'package:race_tracker/widget/app_content.dart';
import 'package:race_tracker/widget/app_header.dart';
import 'package:race_tracker/widget/app_overlay.dart';
import 'package:collection/collection.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with SingleTickerProviderStateMixin {
  // Selected segment
  String _selectedSegment = "Run";

  // Animation controller for card press
  late AnimationController _animationController;

  // Currently animating BIB
  int? _animatingBib;

  // Loading state
  bool _isLoading = true;

  // Search query for filtering by bib
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    // Find the participant by bib
    Participant? participant;
    try {
      participant = participantProvider.participants.firstWhereOrNull(
        (p) => p.bib == bib,
      );
    } catch (e) {
      debugPrint("Participant with bib $bib not found.");
      return;
    }

    if (participant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Participant with BIB #$bib not found."),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if a stamp for the current segment already exists
    final alreadyStamped = participant.stamps.firstWhereOrNull(
      (s) => s.segment.toLowerCase() == _selectedSegment.toLowerCase(),
    );

    if (alreadyStamped != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("BIB #$bib already has a $_selectedSegment stamp"),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create and add the stamp
    Stamp stamp = Stamp(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      newSegment: _selectedSegment,
      newTime: DateTime.now(),
      bib: bib,
    );
    Logger().i(stamp);
    try {
      await stampProvider.addStampToParticipant(stamp, bib);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$_selectedSegment stamp recorded for BIB #$bib"),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error adding stamp: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add stamp for BIB #$bib"),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRemoveStampForBib(Stamp stamp, int bib) async {
    final stampProvider = Provider.of<StampProvider>(context, listen: false);
    final participantProvider = Provider.of<ParticipantProvider>(
      context,
      listen: false,
    );

    // Find the participant by bib
    Participant? participant;
    Logger().i(participant);
    try {
      participant = participantProvider.participants.firstWhereOrNull(
        (p) => p.bib == bib,
      );
    } catch (e) {
      debugPrint("Participant with bib $bib not found.");
      return;
    }

    if (participant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Participant with BIB #$bib not found."),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the stamp for the selected segment
    Stamp? stampToRemove;
    Logger().i(stampToRemove);
    try {
      stampToRemove = participant.stamps.firstWhereOrNull(
        (s) => s.segment.toLowerCase() == _selectedSegment.toLowerCase(),
      );
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

    if (stampToRemove == null) {
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
      await stampProvider.removeStampFromParticipant(stampToRemove, bib);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$_selectedSegment stamp removed for BIB #$bib"),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to remove stamp for BIB #$bib"),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final participantProvider = context.watch<ParticipantProvider>();
    final raceProvider = context.watch<RaceProvider>();

    // Filter participants based on the search query (by bib)
    List<Participant> filteredParticipants =
        participantProvider.participants
            .where((p) => p.bib.toString().contains(_searchQuery))
            .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          AppBackground(),

          // Overlay
          AppOverlay(),

          // Header
          AppHeader(title: 'Tracker'),

          // Main Content
          AppContent(
            content:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Timer display - using global timer from RaceProvider
                              TrackTimer(raceProvider: raceProvider),
                              const Spacer(),
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Search by BIB',
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TrackContent(
                            raceProvider: raceProvider,
                            participants: filteredParticipants,
                            handleAddStampForBib: _handleAddStampForBib,
                            handleRemoveStampForBib: _handleRemoveStampForBib,
                            fetchData: _fetchData,
                            selectedSegment: _selectedSegment,
                            onSegmentSelected: (segment) {
                              setState(() {
                                _selectedSegment = segment;
                              });
                            },
                            animatingBib: _animatingBib,
                            isRaceActive: raceProvider.isRaceActive,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavbar(),
    );
  }
}
