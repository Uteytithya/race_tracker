import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/participant/participant_form_screen.dart';
import 'package:race_tracker/views/participant/widget/participant_list.dart';
import 'package:race_tracker/views/participant/widget/participant_table_header.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.isLoading,
    required this.participants,
    required this.fetchParticipants,
    required this.participantProvider,
  });

  final bool isLoading;
  final List<Participant> participants;
  final RefreshCallback fetchParticipants;
  final ParticipantProvider participantProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 200,
              child: const Text(
                'Participant List',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Row(
              children: [
                // Refresh button
                IconButton(
                  onPressed: fetchParticipants,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParticipantFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Table Header
        ParticipantTableHeader(),

        const SizedBox(height: 10),

        // Participant List
        ParticipantList(
          participants: participantProvider.participants,
          isLoading: isLoading,
          fetchParticipants: fetchParticipants,
          participantProvider: participantProvider,
        ),
      ],
    );
  }
}
