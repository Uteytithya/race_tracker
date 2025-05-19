import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/views/result/widget/result_content.dart';
import 'package:race_tracker/views/result/widget/result_tab_bar.dart';
import 'package:race_tracker/widget/app_background.dart';
import 'package:race_tracker/widget/app_content.dart';
import 'package:race_tracker/widget/app_header.dart';
import 'package:race_tracker/widget/app_bottom_navbar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Constants
  static const List<String> _segments = ['Overall', 'Swim', 'Cycle', 'Run'];

  // State
  bool _isLoading = true;
  String _selectedSegment = 'Overall';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        context.read<ParticipantProvider>().fetchParticipants(),
        context.read<RaceProvider>().fetchRaceData(),
      ]);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();
    final raceProvider = context.watch<RaceProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Stack(
          children: [
            // Background
            AppBackground(),
            // Header
            AppHeader(title: 'Race Results'),

            // Main content
            AppContent(
              tabBar: ResultTabBar(
                context: context,
              ),
              content: ResultContent(
                segments: _segments,
                isLoading: _isLoading,
                selectedSegment: _selectedSegment,
                elapsedTime: raceProvider.elapsedTime,
                filteredParticipants: participantProvider
                    .getFilteredParticipants(
                      participantProvider.participants,
                      _selectedSegment,
                    ),
                onSegmentChanged: (value) {
                  setState(() {
                    _selectedSegment = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavbar(),
    );
  }
}
