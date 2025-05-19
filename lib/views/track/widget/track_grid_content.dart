import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/views/track/widget/track_grid.dart';

class TrackGridContent extends StatelessWidget {
  const TrackGridContent({
    super.key,
    required this.participants,
    required this.segments,
    required this.fetchData,
    required this.selectedSegment,
    this.animatingBib,
    required this.handleAddStampForBib,
    required this.handleRemoveStampForBib,
  });

  final bool isLoading = false;
  final List<Participant> participants;
  final List<String> segments;
  final RefreshCallback fetchData;
  final String selectedSegment;
  final int? animatingBib;
  final Function(int bib) handleAddStampForBib;
  final Function(Stamp stamp, int bib) handleRemoveStampForBib;


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
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
                      onPressed: fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4758E0),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              )
              : TrackGrid(
                participants: participants,
                selectedSegment: selectedSegment,
                animatingBib: animatingBib,
                handleAddStampForBib: handleAddStampForBib,
                handleRemoveStampForBib: handleRemoveStampForBib,
                fetchData: fetchData,
              ),
    );
  }
}
