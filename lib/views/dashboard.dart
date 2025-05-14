import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/views/participant/widget/participant_tile.dart';
import 'package:race_tracker/widget/navbar.dart';
import '../../provider/participant_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final participants = context.watch<ParticipantProvider>().participants;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.2)),

          // Header
          Column(
            children: [
              const SizedBox(height: 80),
              Row(
                children: [
                  Container(
                    width: 300,
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Dashboard',
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Participant List Section
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4758E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 200,
                        child: Text(
                          'Participant List',
                          style: theme.textTheme.displayLarge,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 200,
                        child: Text(
                          'Participant List',
                          style: theme.textTheme.displayLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create');
                        },
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101248),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('BIB', style: theme.textTheme.labelSmall),
                        Container(
                          width: 200,
                          margin: const EdgeInsets.only(left: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Participant',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Participant List
                  Expanded(
                    child: FutureBuilder<List<Participant>>(
                      future: participants,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Error loading participants',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              'No participants yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        } else {
                          final participants = snapshot.data!;
                          return ListView.builder(
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              final participant = participants[index];

                              return Dismissible(
                                key: Key(participant.bib.toString()),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  final removed = participant;

                                  context
                                      .read<ParticipantProvider>()
                                      .removeParticipant(removed);

                                  showCustomToast(
                                    context: context,
                                    message: 'Participant removed',
                                    onUndo: () {
                                      context
                                          .read<ParticipantProvider>()
                                          .addParticipant(removed);
                                    },
                                  );
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit',
                                      arguments: participant,
                                    );
                                  },
                                  child: ParticipantTile(
                                    participant: participant,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
