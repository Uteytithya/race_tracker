import 'package:race_tracker/model/stamp.dart';

abstract class StampRepository {
  Future<void> addStamp(Stamp stamp);
  Future<List<Stamp>> getAllStamps();
  Future<void> deleteStamp(String id);
  Future<void> updateStamp(Stamp stamp);
  Future<Stamp?> getStampById(String id);
}