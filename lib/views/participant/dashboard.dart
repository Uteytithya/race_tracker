import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/views/participant/widget/participant_tile.dart';
import 'package:race_tracker/widget/navbar.dart';
import '../../../provider/participant_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final participants = context.watch<ParticipantProvider>().participants;

    return Scaffold(
      body: Stack(
        children: [
          // Background (full screen image)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Semi-transparent overlay (optional)
          Container(color: Colors.black.withOpacity(0.2)),

          // Content
          Column(
            children: [
              const SizedBox(height: 80), // Space from top
              Row(
                children: [
                  Container(
                    width: 300,
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
            ],
          ),

          // Floating Participant List
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
                  // Title and Add Button
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

                  // Table Header (BIB and Participant)
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
                        Text(
                          'BIB',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 200,
                          margin: const EdgeInsets.only(left: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Participant',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Participant List
                  Expanded(
                    child:
                        participants.isEmpty
                            ? const Center(
                              child: Text(
                                'No participants yet',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                            : ListView.builder(
                              itemCount: participants.length,
                              itemBuilder: (context, index) {
                                return ParticipantTile(
                                  participant: participants[index],
                                );
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
