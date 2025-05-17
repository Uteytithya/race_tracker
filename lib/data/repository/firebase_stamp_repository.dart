import 'package:firebase_database/firebase_database.dart';
import 'package:race_tracker/data/dto/stamp_dto.dart';
import 'package:race_tracker/model/stamp.dart';

class FirebaseStampRepository {
  final DatabaseReference _stampRef = FirebaseDatabase.instance.ref("stamps");
  final DatabaseReference _participantRef = FirebaseDatabase.instance.ref("participants");

  /// Adds a stamp to the global `stamps` node (no `bib` association).
  Future<void> addStamp(Stamp stamp) async {
    try {
      await _stampRef.child(stamp.id).set(StampDto.toJson(stamp));
    } catch (e) {
      throw Exception("Error adding stamp: $e");
    }
  }

  /// Associates a stamp with a participant and removes it from the global `stamps` node.
  Future<void> addStampToParticipant(Stamp stamp, int bib) async {
    try {
      // Add the stamp to the participant's `stamps` node
      await _participantRef
          .child(bib.toString())
          .child("stamps")
          .child(stamp.id)
          .set(StampDto.toJson(stamp));

      // Remove the stamp from the global `stamps` node
      await _stampRef.child(stamp.id).remove();
    } catch (e) {
      throw Exception("Error adding stamp to participant: $e");
    }
  }

  /// Deletes a stamp from the global `stamps` node.
  Future<void> deleteStamp(String id) async {
    try {
      await _stampRef.child(id).remove();
    } catch (e) {
      throw Exception("Error deleting stamp: $e");
    }
  }

  /// Fetches all stamps from the global `stamps` node.
  Future<List<Stamp>> getAllStamps() async {
    try {
      final snapshot = await _stampRef.get();
      if (!snapshot.exists) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((entry) {
        return StampDto.fromJson(Map<String, dynamic>.from(entry.value));
      }).toList();
    } catch (e) {
      throw Exception("Error fetching stamps: $e");
    }
  }
}