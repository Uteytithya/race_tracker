import 'package:firebase_database/firebase_database.dart';
import 'package:race_tracker/data/dto/race_dto.dart';
import 'package:race_tracker/data/repository/race/race_repository.dart';
import 'package:race_tracker/model/race.dart';

class FirebaseRaceRepository extends RaceRepository {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  

  @override
  Future<void> addRace(Race race) async {
    await _db.child("raceStatus").set(RaceDto.toJson(race));
    await _db.child("segments").set(race.segments);
  }

  @override
  Future<Race?> getRace(String id) async {
    final raceStatusSnap = await _db.child("raceStatus").get();
    final segmentsSnap = await _db.child("segments").get();

    if (raceStatusSnap.exists && segmentsSnap.exists) {
      final raceStatus = Map<String, dynamic>.from(raceStatusSnap.value as Map);
      final segments = List<String>.from(segmentsSnap.value as List);
      return RaceDto.fromJson(raceStatus, segments);
    }

    return null;
  }

  @override
  Future<List<Race>> getAllRaces() async {
    final race = await getRace("current"); // Only one race in current design
    return race != null ? [race] : [];
  }

  @override
  Future<void> updateRace(String id, Race race) async {
    await _db.child("raceStatus").update(RaceDto.toJson(race));
    await _db.child("segments").set(race.segments);
  }

  @override
  Future<void> deleteRace(String id) async {
    await _db.child("raceStatus").remove();
    await _db.child("segments").remove();
  }
}
