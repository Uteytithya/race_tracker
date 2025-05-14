import 'package:firebase_database/firebase_database.dart';
import 'package:race_tracker/data/dto/stamp_dto.dart';
import 'package:race_tracker/data/repository/stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';

class FirebaseStampRepository extends StampRepository {
  final DatabaseReference _stampRef = FirebaseDatabase.instance.ref("stamps");

  @override
  Future<void> addStamp(Stamp stamp) async {
    await _stampRef.child(stamp.id).set(StampDto.toJson(stamp));
  }

  @override
  Future<void> deleteStamp(String key) async {
    await _stampRef.child(key).remove();
  }

  @override
  Future<List<Stamp>> getAllStamps() async {
    final snapshot = await _stampRef.get();
    if (!snapshot.exists) return [];

    final stampsMap = snapshot.value as Map<Object?, Object?>;

    final stamps = stampsMap.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      return StampDto.fromJson(data);
    }).toList();

    final maxIdNum = stamps.fold<int>(0, (prev, s) {
      final match = RegExp(r'S-(\d{3})').firstMatch(s.id);
      if (match != null) {
        final num = int.tryParse(match.group(1) ?? '0') ?? 0;
        return num > prev ? num : prev;
      }
      return prev;
    });

    Stamp.setIdCounter(maxIdNum + 1);

    return stamps;
  }

  @override
  Future<Stamp?> getStampById(String id) async {
    final snapshot = await _stampRef.child(id).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return StampDto.fromJson(data);
  }

  @override
  Future<void> updateStamp(Stamp stamp) async {
    final snapshot = await _stampRef.child(stamp.id).get();
    if (snapshot.exists) {
      if (stamp.bib != null && stamp.bib! > 0) {
        // Transfer the stamp to the participant's stamp list
        final participantRef =
            FirebaseDatabase.instance.ref("participants");
        await participantRef
            .child(stamp.bib.toString())
            .child("stamps")
            .child(stamp.id)
            .set(StampDto.toJson(stamp));
        // Remove the stamp from the main stamps structure
        await _stampRef.child(stamp.id).remove();
      } else {
        // No bib assigned; perform a normal update
        await _stampRef.child(stamp.id).update(StampDto.toJson(stamp));
      }
    } else {
      throw Exception("Stamp not found");
    }
  }
}