import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/result/widget/result_display.dart';
import 'package:race_tracker/views/result/widget/result_timer.dart';

class ResultContent extends StatelessWidget {
  const ResultContent({
    super.key,
    required this.segments,
    required this.isLoading,
    required this.selectedSegment,
    required this.elapsedTime,
    required this.filteredParticipants,
    required this.onSegmentChanged,
  });

  // Constants
  final List<String> segments;
  final bool isLoading;
  final String selectedSegment;
  final String elapsedTime;
  final List<Participant> filteredParticipants;
  final ValueChanged<String> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Race timer
        ResultTimer(elapsedTime: elapsedTime),

        // Results
        isLoading
            ? const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
            : Expanded(
              child: ResultDisplay(
                selectedSegment: selectedSegment,
                segments: segments,
                filteredParticipants: filteredParticipants,
                onSegmentChanged: onSegmentChanged,
              ),
            ),
      ],
    );
  }
}
