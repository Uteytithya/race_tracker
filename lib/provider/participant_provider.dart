import 'package:flutter/material.dart';
import 'package:race_tracker/data/repository/firebase_participant_repository.dart';
import '../model/participant.dart';

class ParticipantProvider extends ChangeNotifier {
  final FirebaseParticipantRepository _repository = FirebaseParticipantRepository();

  Future<List<Participant>> get participants => _repository.getAllParticipants();

  void addParticipant(Participant participant) {
    _repository.addParticipant(participant);
    notifyListeners();
  }

  void removeParticipant(Participant participant) {
    _repository.removeParticipant(participant);
    notifyListeners();
  }

  void updateParticipant(int index, Participant updatedParticipant) {
    _repository.updateParticipant(index, updatedParticipant);
    notifyListeners();
  }

  void clearParticipants() {
    _repository.clearParticipants();
    notifyListeners();
  }

  Future<Participant?> getByBib(int bib) {
    return _repository.getParticipantByBib(bib);
  }
}
