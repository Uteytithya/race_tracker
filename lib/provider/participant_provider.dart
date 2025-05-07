import 'package:flutter/material.dart';
import '../model/participant.dart';
import '../data/repository/mock_participant_repository.dart';

class ParticipantProvider extends ChangeNotifier {
  final ParticipantRepository _repository = ParticipantRepository();

  List<Participant> get participants => _repository.getAll();

  void addParticipant(Participant participant) {
    _repository.add(participant);
    notifyListeners();
  }

  void removeParticipant(Participant participant) {
    _repository.remove(participant);
    notifyListeners();
  }

  void updateParticipant(int index, Participant updatedParticipant) {
    _repository.update(index, updatedParticipant);
    notifyListeners();
  }

  void clearParticipants() {
    _repository.clear();
    notifyListeners();
  }

  Participant? getByBib(int bib) {
    return _repository.getByBib(bib);
  }
}
