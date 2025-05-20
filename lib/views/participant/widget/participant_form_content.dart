import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/participant/widget/participant_form.dart';

class ParticipantFormContent extends StatelessWidget {
  const ParticipantFormContent({
    super.key,
    required this.isEditing,
    required this.participant,
  });

  final bool isEditing;
  final Participant? participant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ParticipantForm(
            participant:
                participant, // Pass the participant for editing
          ),
        ),
      ],
    );
  }
}
