import 'package:race_tracker/model/race.dart';

abstract class RaceRepository {
  Future<void> addRace(Race race);
  Future<Race?> getRace(String id);
  Future<List<Race>> getAllRaces();
  Future<void> updateRace(String id, Race race);
  Future<void> deleteRace(String id);
}