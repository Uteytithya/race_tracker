import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/utils/time_calculator.dart';
import 'package:race_tracker/widget/navbar.dart';

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
    final participants = context.watch<ParticipantProvider>().participants;
    final raceProvider = context.watch<RaceProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Stack(
          children: [
            // Background
            _buildBackground(),
            
            // Header
            _buildHeader(),
            
            // Main content
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
                    // Navigation tabs
                    _buildTabBar(),
                    
                    // Race timer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Race Time: ${raceProvider.elapsedTime}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Results
                    _isLoading
                        ? const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        : Expanded(
                            child: _buildResults(participants),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Header_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(color: Colors.black.withOpacity(0.2)),
    );
  }

  Widget _buildHeader() {
    return const Positioned(
      top: 80,
      left: 20,
      child: Text(
        'Race Results',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Status tab
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/race'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Results tab (active)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4758E0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
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
        ],
      ),
    );
  }

  Widget _buildResults(List<Participant> participants) {
    return Column(
      children: [
        // Segment selector header
        _buildSegmentHeader(),
        
        // Participant list
        Expanded(
          child: participants.isEmpty
              ? const Center(
                  child: Text(
                    'No participants found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : _buildParticipantList(participants),
        ),
      ],
    );
  }

  Widget _buildSegmentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedSegment == 'Overall'
                ? 'Overall Results'
                : '$_selectedSegment Results',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildSegmentDropdown(),
        ],
      ),
    );
  }

  Widget _buildSegmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: _selectedSegment,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        elevation: 16,
        underline: Container(height: 0),
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF354AC2),
        onChanged: (String? value) {
          if (value != null) {
            setState(() => _selectedSegment = value);
          }
        },
        items: _segments.map((value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildParticipantList(List<Participant> allParticipants) {
    // Get filtered & sorted participants for current segment
    final filteredParticipants = _getFilteredParticipants(allParticipants);

    if (filteredParticipants.isEmpty) {
      return const Center(
        child: Text(
          'No results available for this segment',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredParticipants.length,
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final participant = filteredParticipants[index];
        final position = index + 1;

        return _buildParticipantTile(participant, position);
      },
    );
  }

  Widget _buildParticipantTile(Participant participant, int position) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4758E0),
          child: Text(
            '$position',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          participant.name,
          style: const TextStyle(
            color: Color(0xFF4758E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Bib: ${participant.bib}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getParticipantTime(participant),
              style: const TextStyle(
                color: Color(0xFF4758E0),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _selectedSegment,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  List<Participant> _getFilteredParticipants(List<Participant> participants) {
    try {
      // Filter valid participants for this segment
      final validParticipants = participants.where((p) {
        // Must have start time
        if (p.startTime == null) return false;

        // Segment-specific filtering
        if (_selectedSegment == 'Overall') {
          return p.stamps.isNotEmpty;
        } else {
          return p.stamps.any((s) => 
            s.segment.toLowerCase() == _selectedSegment.toLowerCase());
        }
      }).toList();

      // Sort the participants
      _sortParticipantsByTime(validParticipants);
      
      return validParticipants;
    } catch (e) {
      debugPrint('Error filtering participants: $e');
      return [];
    }
  }

  void _sortParticipantsByTime(List<Participant> participants) {
    if (_selectedSegment == 'Overall') {
      // Sort by total race time
      participants.sort((a, b) {
        final aTimeMap = TimeCalculator.calculateTimes(
          raceStart: a.startTime!,
          stamps: a.stamps,
        );
        final bTimeMap = TimeCalculator.calculateTimes(
          raceStart: b.startTime!,
          stamps: b.stamps,
        );
        return _compareTimeStrings(aTimeMap['totalTime'], bTimeMap['totalTime']);
      });
    } else {
      // Sort by segment completion time
      participants.sort((a, b) {
        final aStamps = a.stamps.where((s) => 
          s.segment.toLowerCase() == _selectedSegment.toLowerCase()).toList();
        final bStamps = b.stamps.where((s) => 
          s.segment.toLowerCase() == _selectedSegment.toLowerCase()).toList();
        
        if (aStamps.isEmpty && bStamps.isEmpty) return 0;
        if (aStamps.isEmpty) return 1;
        if (bStamps.isEmpty) return -1;
        
        return aStamps.first.time.compareTo(bStamps.first.time);
      });
    }
  }

  int _compareTimeStrings(String timeA, String timeB) {
    try {
      final partsA = timeA.split(':');
      final partsB = timeB.split(':');
      
      // Compare hours
      final hoursA = int.tryParse(partsA[0]) ?? 0;
      final hoursB = int.tryParse(partsB[0]) ?? 0;
      if (hoursA != hoursB) return hoursA.compareTo(hoursB);
      
      // Compare minutes
      final minutesA = int.tryParse(partsA[1]) ?? 0;
      final minutesB = int.tryParse(partsB[1]) ?? 0;
      if (minutesA != minutesB) return minutesA.compareTo(minutesB);
      
      // Compare seconds
      final secPartsA = partsA[2].split('.');
      final secPartsB = partsB[2].split('.');
      final secondsA = int.tryParse(secPartsA[0]) ?? 0;
      final secondsB = int.tryParse(secPartsB[0]) ?? 0;
      if (secondsA != secondsB) return secondsA.compareTo(secondsB);
      
      // Compare milliseconds if present
      if (secPartsA.length > 1 && secPartsB.length > 1) {
        final msA = int.tryParse(secPartsA[1]) ?? 0;
        final msB = int.tryParse(secPartsB[1]) ?? 0;
        return msA.compareTo(msB);
      }
      
      return 0;
    } catch (e) {
      debugPrint('Error comparing times: $e');
      return 0;
    }
  }

  String _getParticipantTime(Participant participant) {
    try {
      if (_selectedSegment == 'Overall') {
        return TimeCalculator.calculateTimes(
          raceStart: participant.startTime!,
          stamps: participant.stamps,
        )['totalTime'];
      } else {
        final segmentStamps = participant.stamps.where((s) => 
          s.segment.toLowerCase() == _selectedSegment.toLowerCase()).toList();
        
        if (segmentStamps.isNotEmpty) {
          return TimeCalculator.calculateSegmentTime(
            participant.startTime!,
            segmentStamps.first.time,
          );
        }
        return "N/A";
      }
    } catch (e) {
      debugPrint('Error getting time for ${participant.name}: $e');
      return "Error";
    }
  }
}

// Extension method for TimeCalculator
extension TimeCalculatorExtension on TimeCalculator {
  static String calculateSegmentTime(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = ((duration.inMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds.$milliseconds';
  }
}