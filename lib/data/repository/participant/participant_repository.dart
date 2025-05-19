import 'package:race_tracker/model/participant.dart';

abstract class ParticipantRepository {
  Future<List<Participant>> getAllParticipants();
  Future<void> addParticipant(Participant participant);
  Future<void> removeParticipant(Participant participant);
  Future<void> updateParticipant(int index, Participant updatedParticipant);
  Future<void> clearParticipants();
  Future<Participant?> getParticipantByBib(int bib);  
  
}