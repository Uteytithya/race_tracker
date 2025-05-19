import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/result/widget/result_participant_tile.dart';

class ResultParticipantList extends StatelessWidget {
  const ResultParticipantList({
    super.key,
    required this.filteredParticipants,
    required this.selectedSegment,
  });

  final List<Participant> filteredParticipants;
  final String selectedSegment;

  @override
  Widget build(BuildContext context) {
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
        final time = participant.getParticipantTime(
          participant,
          selectedSegment,
        );

        return ResultParticipantTile(
          participant: participant,
          position: position,
          selectedSegment: selectedSegment,
          time: time,
        );
      },
    );
  }
}
