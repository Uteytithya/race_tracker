import 'package:race_tracker/repository/participant_mock.dart';

import '../model/participant.dart';


class ParticipantRepository {
  final List<Participant> _participants = [...mockParticipants];

  List<Participant> getAll() {
    return List.unmodifiable(_participants);
  }

  void add(Participant participant) {
    _participants.add(participant);
  }

  void remove(Participant participant) {
    _participants.remove(participant);
  }

  void update(int index, Participant updatedParticipant) {
    if (index >= 0 && index < _participants.length) {
      _participants[index] = updatedParticipant;
    }
  }

  void clear() {
    _participants.clear();
  }

  Participant? getByBib(int bib) {
    try {
      return _participants.firstWhere((p) => p.bib == bib);
    } catch (_) {
      return null;
    }
  }
}
