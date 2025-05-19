import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/stamp/firebase_stamp_repository.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/participant_provider.dart';

class StampProvider extends ChangeNotifier {
  final List<Stamp> _stamps = [];
  final Logger logger = Logger();
  final FirebaseStampRepository _repository = FirebaseStampRepository();
  final ParticipantProvider _participantProvider = ParticipantProvider();

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
    logger.i(stamp);
    try {
      stamp.bib = bib; // Update the stamp with the bib

      final Participant? participant = await _participantProvider.getByBib(bib);

      if (participant == null) {
        logger.e("Participant with bib $bib not found");
        return;
      } else {
        logger.i(participant.stamps);
      }

      if (stamp.segment == participant.stamps.firstWhere(
            (s) => s.segment == stamp.segment
          )) {
        logger.i("Stamp already exists for BIB #$bib");
        return;
      }

      await _repository.addStampToParticipant(stamp, bib);

      logger.i("Stamps before adding: ${participant.stamps}");

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
