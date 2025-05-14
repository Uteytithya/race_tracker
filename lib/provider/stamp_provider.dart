import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/firebase_stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';

class StampProvider extends ChangeNotifier {
  final List<Stamp> _stamps = [];

  final Logger logger = Logger();

  List<Stamp> get stamps => _stamps;

  final FirebaseStampRepository _repository = FirebaseStampRepository();

  Future<void> getStamps() async {
    _stamps.clear();
    _stamps.addAll(await _repository.getAllStamps());
    notifyListeners();
  }

  void addStamp(Stamp stamp) {
    _stamps.add(stamp);
    _repository.addStamp(stamp);
    notifyListeners();
  }

  void removeStamp(Stamp stamp) {
    _stamps.remove(stamp);
    _repository.deleteStamp(stamp.id);
    notifyListeners();
  }

  void clearStamps() {
    _repository.getAllStamps().then((stamps) {
      for (var stamp in stamps) {
        _repository.deleteStamp(stamp.id);
      }
      _stamps.clear();
      notifyListeners();
    });
  }

  void updateStamp(String id) {
    final stamp = _stamps.firstWhere((stamp) => stamp.id == id);
    if (stamp != null) {
      _repository.updateStamp(stamp);
      final index = _stamps.indexOf(stamp);
      _stamps[index] = stamp;
      logger.d("Stamp updated in the repository");
      notifyListeners();
    } else {
      logger.e("Stamp not found");
    }
  }
}