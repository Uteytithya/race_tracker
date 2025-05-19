import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/participant/widget/participant_tile.dart';

class ParticipantList extends StatelessWidget {
  const ParticipantList({
    super.key,
    required this.participants,
    required this.isLoading,
    required this.fetchParticipants,
    required this.participantProvider,
  });

  final List<Participant> participants;
  final bool isLoading;
  final RefreshCallback fetchParticipants;
  final ParticipantProvider participantProvider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : participants.isEmpty
              ? RefreshIndicator(
                onRefresh: fetchParticipants,
                child: ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        'No participants yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchParticipants,
                child: ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return Dismissible(
                      key: Key(participant.bib.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        final removed = participant;
                        participantProvider.removeParticipant(removed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Participant removed'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                participantProvider.addParticipant(removed);
                              },
                            ),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            'editParticipant',
                            arguments: participant,
                          );
                        },
                        child: ParticipantTile(participant: participant),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
