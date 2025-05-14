import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/participant/widget/participant_form.dart';

class EditParticipantScreen extends StatelessWidget {
  const EditParticipantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the participant passed as argument from the route
    final participant = ModalRoute.of(context)!.settings.arguments as Participant;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF4758E0),
      body: Stack(
        children: [
          // Background image with dark overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.2)),

          // Form container
          Positioned(
            top: 120,
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
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Participant',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Form - Pass the participant to edit
                  Expanded(
                    child: SingleChildScrollView(
                      child: ParticipantForm(participant: participant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}