import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/views/participant/widget/participant_form_content.dart';
import 'package:race_tracker/widget/app_background.dart';
import 'package:race_tracker/widget/app_bottom_navbar.dart';
import 'package:race_tracker/widget/app_content.dart';
import 'package:race_tracker/widget/app_header.dart';
import 'package:race_tracker/widget/app_overlay.dart';

class ParticipantFormScreen extends StatelessWidget {
  final Participant? participant;

  const ParticipantFormScreen({super.key, this.participant});

  @override
  Widget build(BuildContext context) {
    final isEditing = participant != null;

    return Scaffold(
      backgroundColor: const Color(0xFF4758E0),
      body: Stack(
        children: [
          // Background image with dark overlay
          AppBackground(),
          AppOverlay(),
          AppHeader(
            title: participant != null ? "Edit Participant" : "Create Participant",
            leading: IconButton(

              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Form container
          AppContent(
            content: ParticipantFormContent(
              isEditing: isEditing,
              participant: participant,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavbar(),
    );
  }
}
