import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/result/widget/result_participant_list.dart';
import 'package:race_tracker/widget/app_segment_dropdown.dart';

class ResultDisplay extends StatelessWidget {
  const ResultDisplay({
    super.key,
    required this.selectedSegment,
    required this.segments,
    required this.filteredParticipants,
    required this.onSegmentChanged,
  });

  final String selectedSegment;
  final List<String> segments;
  final List<Participant> filteredParticipants;
  final ValueChanged<String> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Segment selector header
        AppSegmentHeader(
          selectedSegment: selectedSegment,
          segments: segments,
          onSegmentChanged: (value) {
            onSegmentChanged(value);
          },
        ),

        // Participant list
        Expanded(
          child: filteredParticipants.isEmpty
              ? const Center(
                  child: Text(
                    'No participants found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ResultParticipantList(
                  filteredParticipants: filteredParticipants,
                  selectedSegment: selectedSegment,
                ),
        ),
      ],
    );
  }
}
