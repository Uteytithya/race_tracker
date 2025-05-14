import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

class ParticipantTile extends StatelessWidget {
  final Participant participant;

  const ParticipantTile({
    super.key,
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // BIB Number
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: participant.gender == Gender.male
                    ? theme.primaryColor.withOpacity(0.5)
                    : theme.secondaryHeaderColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Text(
                participant.bib.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Participant Name and Details
            Container(
              width: 200,
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${participant.gender.name}, ${participant.age} years old',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Edit Icon
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}