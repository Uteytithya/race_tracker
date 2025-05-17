import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/firebase_stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';

class StampProvider extends ChangeNotifier {
  final List<Stamp> _stamps = [];
  final Logger logger = Logger();
  final FirebaseStampRepository _repository = FirebaseStampRepository();

  List<Stamp> get stamps => _stamps;

  Future<void> getStamps() async {
    try {
      _stamps.clear();
      _stamps.addAll(await _repository.getAllStamps());
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching stamps: $e");
    }
  }

  Future<void> addStamp(Stamp stamp) async {
    try {
      await _repository.addStamp(stamp);
      _stamps.add(stamp);
      notifyListeners();
      logger.i("Stamp added: ${stamp.id}");
    } catch (e) {
      logger.e("Error adding stamp: $e");
    }
  }

  Future<void> addStampToParticipant(Stamp stamp, int bib) async {
    try {
      stamp.bib = bib; // Update the stamp with the bib
      await _repository.addStampToParticipant(stamp, bib);
      _stamps.removeWhere((s) => s.id == stamp.id); // Remove from local list
      notifyListeners();
      logger.i("Stamp added to participant with bib: $bib");
    } catch (e) {
      logger.e("Error adding stamp to participant: $e");
    }
  }

  void removeStamp(Stamp stamp) {
    try {
      _stamps.remove(stamp);
      _repository.deleteStamp(stamp.id);
      notifyListeners();
    } catch (e) {
      logger.e("Error removing stamp: $e");
    }
  }
}