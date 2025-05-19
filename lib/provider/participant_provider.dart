import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/participant/firebase_participant_repository.dart';
import 'package:race_tracker/utils/time_calculator.dart';
import '../model/participant.dart';

class ParticipantProvider extends ChangeNotifier {
  final FirebaseParticipantRepository _repository =
      FirebaseParticipantRepository();
  final Logger logger = Logger();

  List<Participant> _participants = [];

  List<Participant> get participants => _participants;

  Future<void> fetchParticipants() async {
    try {
      _participants = await _repository.getAllParticipants();
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching participants: $e");
    }
  }

  void addParticipant(Participant participant) async {
    try {
      await _repository.addParticipant(participant);
      _participants.add(participant);
      notifyListeners();
      logger.i("Participant added: ${participant.name}");
    } catch (e) {
      logger.e("Error adding participant: $e");
    }
  }

  void removeParticipant(Participant participant) async {
    try {
      await _repository.deleteParticipant(participant.bib);
      _participants.removeWhere((p) => p.bib == participant.bib);
      notifyListeners();
      logger.i("Participant removed: ${participant.name}");
    } catch (e) {
      logger.e("Error removing participant: $e");
    }
  }

  void updateParticipant(Participant updatedParticipant) async {
    try {
      await _repository.updateParticipant(updatedParticipant);
      final index = _participants.indexWhere(
        (p) => p.bib == updatedParticipant.bib,
      );
      if (index != -1) {
        _participants[index] = updatedParticipant;
        notifyListeners();
        logger.i("Participant updated: ${updatedParticipant.name}");
      }
    } catch (e) {
      logger.e("Error updating participant: $e");
    }
  }

  Future<Participant?> getByBib(int bib) async {
    try {
      return await _repository.getParticipantByBib(bib);
    } catch (e) {
      logger.e("Error fetching participant by bib: $e");
      return null;
    }
  }

  List<Participant> getFilteredParticipants(
    List<Participant> participants,
    String selectedSegment,
  ) {
    try {
      // Filter valid participants for this segment
      final validParticipants =
          participants.where((p) {
            // Must have start time
            if (p.startTime == null) return false;

            // Segment-specific filtering
            if (selectedSegment == 'Overall') {
              return p.stamps.isNotEmpty;
            } else {
              return p.stamps.any(
                (s) => s.segment.toLowerCase() == selectedSegment.toLowerCase(),
              );
            }
          }).toList();

      // Sort the participants
      sortParticipantsByTime(validParticipants, selectedSegment);

      return validParticipants;
    } catch (e) {
      debugPrint('Error filtering participants: $e');
      return [];
    }
  }

  void sortParticipantsByTime(
    List<Participant> participants,
    String selectedSegment,
  ) {
    if (selectedSegment == 'Overall') {
      // Sort by total race time
      participants.sort((a, b) {
        final aTimeMap = TimeCalculator.calculateTimes(
          raceStart: a.startTime!,
          stamps: a.stamps,
        );
        final bTimeMap = TimeCalculator.calculateTimes(
          raceStart: b.startTime!,
          stamps: b.stamps,
        );
        return TimeCalculator.compareTimeStrings(
          aTimeMap['totalTime'],
          bTimeMap['totalTime'],
        );
      });
    } else {
      // Sort by segment completion time
      participants.sort((a, b) {
        final aStamps =
            a.stamps
                .where(
                  (s) =>
                      s.segment.toLowerCase() == selectedSegment.toLowerCase(),
                )
                .toList();
        final bStamps =
            b.stamps
                .where(
                  (s) =>
                      s.segment.toLowerCase() == selectedSegment.toLowerCase(),
                )
                .toList();

        if (aStamps.isEmpty && bStamps.isEmpty) return 0;
        if (aStamps.isEmpty) return 1;
        if (bStamps.isEmpty) return -1;

        return aStamps.first.time.compareTo(bStamps.first.time);
      });
    }
  }
}
