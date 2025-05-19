import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/dto/participant_dto.dart';
import 'package:race_tracker/model/participant.dart';

class FirebaseParticipantRepository {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("participants");
  final Logger logger = Logger();

  Future<List<Participant>> getAllParticipants() async {
    try {
      final snapshot = await _dbRef.get();
      if (!snapshot.exists) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      logger.d("Fetched participants: $data");
      if (data.isEmpty) {
        return [];
      }
      return data.entries.map((entry) {
        return ParticipantDTO.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
      
    } catch (e) {
      logger.e("Error fetching participants: $e");
      return [];
    }
  }

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

  Future<void> updateParticipant(Participant participant) async {
    try {
      await _dbRef.child(participant.bib.toString()).update(
        ParticipantDTO.toJson(participant),
      );
      logger.i("Updated Participant: $participant");
    } catch (e) {
      logger.e("Error updating participant: $e");
    }
  }

  Future<void> deleteParticipant(int bib) async {
    try {
      await _dbRef.child(bib.toString()).remove();
      logger.i("Deleted Participant with bib: $bib");
    } catch (e) {
      logger.e("Error deleting participant: $e");
    }
  }

  Future<Participant?> getParticipantByBib(int bib) async {
    try {
      final snapshot = await _dbRef.child(bib.toString()).get();
      if (!snapshot.exists) {
        return null;
      }
      return ParticipantDTO.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    } catch (e) {
      logger.e("Error fetching participant by bib: $e");
      return null;
    }
  }
}