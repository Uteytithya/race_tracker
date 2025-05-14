import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/dto/participant_dto.dart';
import 'package:race_tracker/model/participant.dart';
import 'participant_repository.dart';

class FirebaseParticipantRepository extends ParticipantRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    "participants",
  );

  final Logger logger = Logger();

  @override
  Future<List<Participant>> getAllParticipants() async {
    try {
      final snapshot = await _dbRef.get();
      if (snapshot.value == null) {
        return [];
      }
      List<Participant> participants = [];
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        Participant.incrementBibCounter();
        participants.add(
          ParticipantDTO.fromJson(Map<String, dynamic>.from(value)),
        );
      });
      logger.i("Participant List: \n$participants");
      return participants;
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error fetching participants: $e");
      return [];
    }
  }

  @override
  Future<void> addParticipant(Participant participant) async {
    try {
      await _dbRef
          .child(participant.bib.toString())
          .set(ParticipantDTO.toJson(participant));
      logger.i("Added Participant: $participant");
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error adding participant: $e");
    }
  }

  @override
  Future<void> removeParticipant(Participant participant) async {
    try {
      logger.i("Removed Participant: $participant");
      await _dbRef.child(participant.bib.toString()).remove();
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error removing participant: $e");
    }
  }

  @override
  Future<void> updateParticipant(
    int index,
    Participant updatedParticipant,
  ) async {
    try {
      await _dbRef
          .child(updatedParticipant.bib.toString())
          .update(ParticipantDTO.toJson(updatedParticipant));
      logger.i("Updated Participant: $updatedParticipant");
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error updating participant: $e");
    }
  }

  @override
  Future<void> clearParticipants() async {
    try {
      await _dbRef.remove();
      logger.i("Clear Participant in Firebase");
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error clearing participants: $e");
    }
  }

  @override
  Future<Participant?> getParticipantByBib(int bib) async {
    try {
      final snapshot = await _dbRef.child(bib.toString()).get();
      if (snapshot.value == null) {
        return null;
      }

      Participant participant = ParticipantDTO.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map<String, dynamic>),
      );

      logger.i("Participant: $participant");
      return participant;
    } catch (e) {
      // Log the error or handle it appropriately
      logger.e("Error fetching participant by bib: $e");
      return null;
    }
  }
}
