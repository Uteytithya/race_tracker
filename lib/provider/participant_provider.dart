import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/firebase_participant_repository.dart';
import '../model/participant.dart';

class ParticipantProvider extends ChangeNotifier {
  final FirebaseParticipantRepository _repository = FirebaseParticipantRepository();
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
      final index = _participants.indexWhere((p) => p.bib == updatedParticipant.bib);
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
}