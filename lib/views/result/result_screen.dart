import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/utils/time_calculator.dart';
import 'package:race_tracker/widget/navbar.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _activeTab = 1;
  String _selectedSegment = 'Overall';
  bool _isLoading = true;
  
  final List<String> _segments = ['Overall', 'Swim', 'Cycle', 'Run'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch both data sources in parallel
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
            // Background with image and overlay
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Header_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            
            // Header with title
            const Positioned(
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
            ),
            
            // Main content area
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
                    // Tab navigation
                    _buildTabBar(),
                    
                    // Race timer display
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
                    
                    // Segment selector and results
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/race'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? const Color(0xFF4758E0) : Colors.white,
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
        // Segment selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedSegment == 'Overall' ? 'Overall Ranking' : '$_selectedSegment Ranking',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildSegmentDropdown(),
            ],
          ),
        ),
        
        // Display results or empty state
        Expanded(
          child: participants.isEmpty 
              ? const Center(
                  child: Text(
                    'No participants found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : _buildRankings(participants),
        ),
      ],
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
        items: _segments.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRankings(List<Participant> allParticipants) {
    // Get valid participants for current segment
    final rankedParticipants = _getFilteredParticipants(allParticipants);
    
    if (rankedParticipants.isEmpty) {
      return const Center(
        child: Text(
          'No results available for this segment',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Split into podium (top 3) and remaining participants
    final podiumParticipants = rankedParticipants.length > 3 
        ? rankedParticipants.sublist(0, 3) 
        : rankedParticipants;
        
    final remainingParticipants = rankedParticipants.length > 3 
        ? rankedParticipants.sublist(3) 
        : <Participant>[];

    return Column(
      children: [
        // Podium display
        SizedBox(
          height: 170,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (podiumParticipants.length >= 2)
                _buildPodiumPosition(podiumParticipants[1], 2, Colors.white, 90, 140),
              const SizedBox(width: 6),
              if (podiumParticipants.isNotEmpty)
                _buildPodiumPosition(podiumParticipants[0], 1, Colors.white, 100, 170),
              const SizedBox(width: 6),
              if (podiumParticipants.length >= 3)
                _buildPodiumPosition(podiumParticipants[2], 3, Colors.white, 80, 110),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Remaining participants list
        Expanded(
          child: remainingParticipants.isEmpty
              ? const Center(
                  child: Text(
                    'No additional participants',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: remainingParticipants.length,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemBuilder: (context, index) {
                    final participant = remainingParticipants[index];
                    final position = index + 4;
                    
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
                        trailing: Text(
                          _getParticipantTime(participant),
                          style: const TextStyle(
                            color: Color(0xFF4758E0),
                            fontWeight: FontWeight.w500,
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

  Widget _buildPodiumPosition(Participant participant, int position, Color color, double width, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: width,
          child: Text(
            participant.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$position', 
                style: const TextStyle(
                  color: Color(0xFF4758E0), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 28
                )
              ),
              const SizedBox(height: 4),
              Text(
                _getParticipantTime(participant), 
                style: const TextStyle(
                  color: Color(0xFF4758E0), 
                  fontWeight: FontWeight.w500, 
                  fontSize: 14
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Simplified filtering and sorting for participants
  List<Participant> _getFilteredParticipants(List<Participant> participants) {
    try {
      // Filter participants with valid data for this segment
      final validParticipants = participants.where((p) {
        // Must have start time
        if (p.startTime == null) return false;
        
        // For overall ranking, need at least one stamp
        if (_selectedSegment == 'Overall') {
          return p.stamps.isNotEmpty;
        }
        
        // For specific segments, need a stamp matching the segment
        return p.stamps.any((s) => 
          s.segment.toLowerCase() == _selectedSegment.toLowerCase());
      }).toList();
      
      // Sort participants
      if (_selectedSegment == 'Overall') {
        // Sort by total time for overall ranking
        validParticipants.sort((a, b) {
          final aTimeMap = TimeCalculator.calculateTimes(
            raceStart: a.startTime!, 
            stamps: a.stamps
          );
          
          final bTimeMap = TimeCalculator.calculateTimes(
            raceStart: b.startTime!, 
            stamps: b.stamps
          );
          
          final aTimeStr = aTimeMap['totalTime'];
          final bTimeStr = bTimeMap['totalTime'];
          
          return _compareTimeStrings(aTimeStr, bTimeStr);
        });
      } else {
        // Sort by segment time
        validParticipants.sort((a, b) {
          // Get stamps for this segment
          final aStamps = a.stamps.where((s) => 
            s.segment.toLowerCase() == _selectedSegment.toLowerCase()).toList();
            
          final bStamps = b.stamps.where((s) => 
            s.segment.toLowerCase() == _selectedSegment.toLowerCase()).toList();
          
          // Handle cases with missing stamps
          if (aStamps.isEmpty && bStamps.isEmpty) return 0;
          if (aStamps.isEmpty) return 1;
          if (bStamps.isEmpty) return -1;
          
          // Compare by segment completion time
          return aStamps.first.time.compareTo(bStamps.first.time);
        });
      }
      
      return validParticipants;
    } catch (e) {
      debugPrint('Error filtering participants: $e');
      return [];
    }
  }

  // Compare time strings in format "HH:MM:SS.MS"
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
      
      // Compare seconds and milliseconds
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

  // Get formatted time for a participant based on selected segment
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
          final segmentTime = TimeCalculator.calculateSegmentTime(
            participant.startTime!,
            segmentStamps.first.time,
          );
          return segmentTime;
        }
        return "N/A";
      }
    } catch (e) {
      debugPrint('Error getting time for ${participant.name}: $e');
      return "Error";
    }
  }
}

// Add this method to your TimeCalculator class if it doesn't exist yet
extension TimeCalculatorExtension on TimeCalculator {
  static String calculateSegmentTime(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = ((duration.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    
    return '$hours:$minutes:$seconds.$milliseconds';
  }
}