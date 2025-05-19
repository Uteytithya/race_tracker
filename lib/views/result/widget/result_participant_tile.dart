import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';

class ResultParticipantTile extends StatelessWidget {
  const ResultParticipantTile({
    super.key,
    required this.participant,
    required this.position,
    required this.selectedSegment,
    required this.time,
  });

  final Participant participant;
  final int position;
  final String selectedSegment;
  final String time;

  @override
  Widget build(BuildContext context) {
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
              time,
              style: const TextStyle(
                color: Color(0xFF4758E0),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              selectedSegment,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
