import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/stamp/firebase_stamp_repository.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:collection/collection.dart';
import 'package:race_tracker/provider/participant_provider.dart';


class StampProvider extends ChangeNotifier {
  final List<Stamp> _stamps = [];
  final Logger logger = Logger();
  final FirebaseStampRepository _repository = FirebaseStampRepository();
  final ParticipantProvider _participantProvider = ParticipantProvider();
  final List<String> _segments = ["Run", "Cycle", "Swim"];

  List<Stamp> get stamps => _stamps;

  Future<void> getStamps() async {
    try {
      _stamps.clear();
      _stamps.addAll(await _repository.getAllStamps());
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching stamps: $e");
    }
  }

  Future<void> addStamp(Stamp stamp) async {
    try {
      await _repository.addStamp(stamp);
      _stamps.add(stamp);
      notifyListeners();
      logger.i("Stamp added: ${stamp.id}");
    } catch (e) {
      logger.e("Error adding stamp: $e");
    }
  }

  Future<void> addStampToParticipant(Stamp stamp, int bib) async {
    logger.i("Attempting to add stamp: $stamp for BIB #$bib");
    try {
      final Participant? participant = _participantProvider.participants
          .firstWhereOrNull((p) => p.bib == bib);

      if (participant == null) {
        logger.e("Participant with bib $bib not found");
        return;
      }

      logger.i("Participant stamps before adding: ${participant.stamps}");

      // Check if the current segment is allowed to be stamped
      final stampedSegments =
          participant.stamps.map((s) => s.segment.toLowerCase()).toSet();
      final requiredSegments = _segments.map((s) => s.toLowerCase()).toList();

      // Find the index of the current segment
      final currentSegmentIndex = requiredSegments.indexOf(
        stamp.segment.toLowerCase(),
      );

      // Ensure all previous segments are stamped (skip for the first segment)
      if (currentSegmentIndex > 0) {
        for (int i = 0; i < currentSegmentIndex; i++) {
          if (!stampedSegments.contains(requiredSegments[i])) {
            logger.i(
              "Cannot stamp segment '${stamp.segment}' because '${requiredSegments[i]}' has not been stamped yet.",
            );
            return;
          }
        }
      }

      // Check if the current segment is already stamped
      final alreadyStamped = participant.stamps.any(
        (s) => s.segment.toLowerCase() == stamp.segment.toLowerCase(),
      );

      if (alreadyStamped) {
        logger.i(
          "Stamp already exists for BIB #$bib in segment ${stamp.segment}",
        );
        return;
      }

      // Add the stamp to Firebase
      await _repository.addStampToParticipant(stamp, bib);

      // Add the stamp to the local participant's stamps list
      participant.stamps.add(stamp);

      // Notify the ParticipantProvider to update the UI
      _participantProvider.notifyListeners();

      logger.i("Participant stamps after adding: ${participant.stamps}");
      notifyListeners();
      logger.i("Stamp added to participant with bib: $bib");
    } catch (e) {
      logger.e("Error adding stamp to participant: $e");
    }
  }

  Future<void> removeStampFromParticipant(Stamp stamp, int bib) async {
    logger.i("Attempting to remove stamp for BIB #$bib: ${stamp.id}");
    try {
      // Remove the stamp from Firebase
      await _repository.removeStampFromParticipant(stamp, bib);

      // Find the participant and remove the stamp locally
      final participant =
          _participantProvider.participants
                  .where((p) => p.bib == bib)
                  .isNotEmpty
              ? _participantProvider.participants.firstWhere(
                (p) => p.bib == bib,
              )
              : null;

      if (participant == null) {
        logger.e("Participant with bib $bib not found");
        return;
      }

      participant.stamps.removeWhere((s) => s.id == stamp.id);

      // Notify the ParticipantProvider to update the UI
      _participantProvider.notifyListeners();

      notifyListeners();
      logger.i("Stamp removed for BIB #$bib: ${stamp.id}");
    } catch (e) {
      logger.e("Error removing stamp for BIB #$bib: $e");
    }
  }
}
