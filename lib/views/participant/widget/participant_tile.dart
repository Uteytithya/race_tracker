import 'package:flutter/material.dart';
import '../../../model/participant.dart';

class ParticipantTile extends StatelessWidget {
  final Participant participant;
  final VoidCallback? onTap;

  const ParticipantTile({
    super.key,
    required this.participant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Text(
              participant.bib.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Container(
              width: 200,
              margin: const EdgeInsets.only(left: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                participant.name,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
