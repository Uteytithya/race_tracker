import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/dto/participant_dto.dart';
import 'package:race_tracker/data/dto/stamp_dto.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'participant_repository.dart';

class FirebaseParticipantRepository extends ParticipantRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("participants");
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
          ParticipantDTO.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        );
      });
      logger.i("Participant List: \n$participants");
      return participants;
    } catch (e) {
      logger.e("Error fetching participants: $e");
      return [];
    }
  }

  @override
  Future<void> addParticipant(Participant participant) async {
    try {
      await _dbRef.child(participant.bib.toString()).set(
        ParticipantDTO.toJson(participant),
      );
      logger.i("Added Participant: $participant");
    } catch (e) {
      logger.e("Error adding participant: $e");
    }
  }

  Future<void> addStampToParticipant(int bib, Stamp stamp) async {
    try {
      await _dbRef
          .child(bib.toString())
          .child("stamps")
          .child(stamp.id)
          .set(StampDto.toJson(stamp));
      logger.i("Added Stamp for Participant $bib: $stamp");
    } catch (e) {
      logger.e("Error adding stamp to participant: $e");
    }
  }

  @override
  Future<void> removeParticipant(Participant participant) async {
    try {
      logger.i("Removed Participant: $participant");
      await _dbRef.child(participant.bib.toString()).remove();
    } catch (e) {
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
      logger.e("Error updating participant: $e");
    }
  }

  @override
  Future<void> clearParticipants() async {
    try {
      await _dbRef.remove();
      logger.i("Cleared Participants in Firebase");
    } catch (e) {
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
      logger.e("Error fetching participant by bib: $e");
      return null;
    }
  }
}