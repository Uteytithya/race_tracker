import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/firebase_stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/participant_provider.dart';

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

      // Debug: Log the stamps before adding
      final participant = ParticipantProvider().participants.firstWhere(
        (p) => p.bib == bib,
      );

      if (participant == null) {
        throw Exception("Participant with bib $bib not found");
      }

      logger.i("Stamps before adding: ${participant.stamps}");

      // Add the stamp to the local participant's stamps list
      participant.stamps.add(stamp);

      // Debug: Log the stamps after adding
      logger.i("Stamps after adding: ${participant.stamps}");

      notifyListeners();
      logger.i("Stamp added to participant with bib: $bib");
    } catch (e) {
      logger.e("Error adding stamp to participant: $e");
    }
  }

  Future<void> removeStampFromParticipant(Stamp stamp, int bib) async {
    logger.i("Stamp removed for BIB #$bib: ${stamp.id}");
    ParticipantProvider participantProvider = ParticipantProvider();
    try {
      await _repository.removeStampFromParticipant(stamp, bib);
      participantProvider.participants
          .firstWhere((p) => p.bib == bib)
          .stamps
          .removeWhere((s) => s.id == stamp.id);
      notifyListeners();
    } catch (e) {
      logger.e("Error removing stamp for BIB #$bib: $e");
    }
  }
}
