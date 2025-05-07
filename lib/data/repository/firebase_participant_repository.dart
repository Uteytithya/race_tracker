import 'package:firebase_database/firebase_database.dart';
import 'package:race_tracker/data/dto/participant_dto.dart';
import 'package:race_tracker/model/participant.dart';
import 'participant_repository.dart';

class FirebaseParticipantRepository extends ParticipantRepository {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("participants");

  @override
  Future<List<Participant>> getAllParticipants() async {
    final snapshot = await _dbRef.get();
    if (snapshot.value == null) {
      return [];
    }
    List<Participant> participants = [];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    data.forEach((key, value) {
      participants.add(ParticipantDTO.fromJson(Map<String, dynamic>.from(value)));
    });
    return participants;
  }

  @override
  Future<void> addParticipant(Participant participant) async {
    // Using the participant bib as the key for easy updates/deletes.
    await _dbRef.child(participant.bib.toString())
        .set(ParticipantDTO.toJson(participant));
  }

  @override
  Future<void> removeParticipant(Participant participant) async {
    await _dbRef.child(participant.bib.toString()).remove();
  }

  @override
  Future<void> updateParticipant(int index, Participant updatedParticipant) async {
    await _dbRef
        .child(updatedParticipant.bib.toString())
        .update(ParticipantDTO.toJson(updatedParticipant));
  }

  @override
  Future<void> clearParticipants() async {
    await _dbRef.remove();
  }

  @override
  Future<Participant?> getParticipantByBib(int bib) async {
    final snapshot = await _dbRef.child(bib.toString()).get();
    if (snapshot.value == null) {
      return null;
    }
    return ParticipantDTO.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
  }
}