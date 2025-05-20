import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/views/track/widget/track_grid_content.dart';
import 'package:race_tracker/views/track/widget/track_segment_tab.dart';

class TrackContent extends StatelessWidget {
  const TrackContent({
    super.key,
    required this.raceProvider,
    required this.participants,
    required this.handleAddStampForBib,
    required this.handleRemoveStampForBib,
    required this.fetchData,
    required this.selectedSegment,
    required this.onSegmentSelected,
    this.animatingBib,
    required this.isRaceActive,
  });

  final RaceProvider raceProvider;
  final List<Participant> participants;
  final int? animatingBib;
  final Function(int bib) handleAddStampForBib;
  final Function(Stamp stamp, int bib) handleRemoveStampForBib;
  final RefreshCallback fetchData;
  final String selectedSegment;
  final ValueChanged<String> onSegmentSelected;
  final bool isRaceActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Segment Sub-Tabs
        TrackSegmentTab(
          selectedSegment: selectedSegment,
          onSegmentSelected: (segment) {
            onSegmentSelected(segment);
          },
        ),

        // BIB Grid Content
        isRaceActive
            ? TrackGridContent(
              participants: participants,
              segments: ['Run', 'Cycle', 'Swim'],
              fetchData: fetchData,
              selectedSegment: selectedSegment,
              animatingBib: animatingBib,
              handleAddStampForBib: handleAddStampForBib,
              handleRemoveStampForBib: handleRemoveStampForBib,
            )
            : const Center(
              child: Text(
                'The race has not started yet.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      ],
    );
  }
}
