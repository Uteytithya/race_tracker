import 'package:firebase_database/firebase_database.dart';
import 'package:race_tracker/data/dto/stamp_dto.dart';
import 'package:race_tracker/data/repository/stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';

class FirebaseStampRepository extends StampRepository {
  final DatabaseReference _stampRef = FirebaseDatabase.instance.ref("stamps");

  @override
  Future<void> addStamp(Stamp stamp) async {
    await _stampRef.push().set(StampDto.toJson(stamp));
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
    return stampsMap.entries.map((entry) {
      final data = Map<String, dynamic>.from(entry.value as Map);
      return StampDto.fromJson(data);
    }).toList();
  }
}