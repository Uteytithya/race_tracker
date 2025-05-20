import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/data/repository/stamp/firebase_stamp_repository.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:collection/collection.dart';
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
    logger.i("Attempting to add stamp: $stamp for BIB #$bib");
    try {
      final participant = _participantProvider.participants.firstWhereOrNull(
        (p) => p.bib == bib,
      );
      logger.i(_participantProvider.participants.first);
      logger.i(participant);
      if (participant == null) {
        logger.e("Participant with bib $bib not found");
        return;
      }

      logger.i("Participant stamps before adding: ${participant.stamps}");

      await _repository.addStampToParticipant(stamp, bib);

      participant.stamps.add(stamp);

      _participantProvider.notifyListeners();

      logger.i("Participant stamps after adding: ${participant.stamps}");
      notifyListeners();
      logger.i("Stamp added to participant with bib: $bib");
    } catch (e) {
      logger.e("Error adding stamp to participant: $e");
    }
  }

  Future<void> removeStampFromParticipant(Stamp stamp, int bib) async {
    logger.i("Attempting to remove stamp for BIB #$bib: ${stamp.id}");
    try {
      await _repository.removeStampFromParticipant(stamp, bib);

      final participant =
          _participantProvider.participants
                  .where((p) => p.bib == bib)
                  .isNotEmpty
              ? _participantProvider.participants.firstWhere(
                (p) => p.bib == bib,
              )
              : null;

      if (participant == null) {
        logger.e("Participant with bib $bib not found");
        return;
      }

      participant.stamps.removeWhere((s) => s.id == stamp.id);

      _participantProvider.notifyListeners();

      notifyListeners();
      logger.i("Stamp removed for BIB #$bib: ${stamp.id}");
    } catch (e) {
      logger.e("Error removing stamp for BIB #$bib: $e");
    }
  }
}
