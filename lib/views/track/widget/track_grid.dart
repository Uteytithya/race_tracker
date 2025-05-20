import 'package:flutter/material.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/utils/icon.dart';

class TrackGrid extends StatelessWidget {
  const TrackGrid({
    super.key,
    required this.participants,
    required this.selectedSegment,
    this.animatingBib,
    required this.handleAddStampForBib,
    required this.handleRemoveStampForBib,
    required this.fetchData,
  });

  final List<Participant> participants;
  final String selectedSegment;
  final int? animatingBib;
  final Function(int bib) handleAddStampForBib;
  final Function(Stamp stamp, int bib) handleRemoveStampForBib;
  final RefreshCallback fetchData;

  @override
  Widget build(BuildContext context) {
    final activeParticipants =
        participants
            .where((p) => p.status != ParticipantStatus.finished)
            .toList();

    if (activeParticipants.isEmpty) {
      return const Center(
        child: Text(
          'No active participants to track',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: activeParticipants.length,
        itemBuilder: (context, index) {
          final participant = activeParticipants[index];
          final bool isAnimating = animatingBib == participant.bib;
          // Inside _buildBibGrid
          return GestureDetector(
            onTap: () => handleAddStampForBib(participant.bib),
            onLongPress:
                () => handleRemoveStampForBib(
                  participant.stamps.firstWhere(
                    (s) => s.segment.toLowerCase() ==
                        selectedSegment.toLowerCase(),
                  ),
                  participant.bib,
                ),
            child: AnimatedScale(
              scale: isAnimating ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${participant.bib}',
                      style: const TextStyle(
                        color: Color(0xFF4758E0),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      participant.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4758E0),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      AppIcon.getIconForSegment(selectedSegment),
                      color: const Color(0xFF4758E0),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
