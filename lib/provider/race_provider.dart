import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/utils/enum.dart';

class RaceProvider with ChangeNotifier {
  

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  late ParticipantProvider _participantProvider;
  late StampProvider _stampProvider;

  void updateProviders(ParticipantProvider pp, StampProvider sp) {
    _participantProvider = pp;
    _stampProvider = sp;
    notifyListeners();
  }

  RaceProvider() {
    fetchRaceData();
  }

  final Logger logger = Logger();
  final List<String> segments = [
    "Run",
    "Cycle",
    "Swim",
  ];
  bool _isRaceActive = false;
  DateTime? _raceStartTime;
  DateTime? _raceEndTime;
  String _elapsedTime = "00:00:00";
  Timer? _timer;
  List<Participant> get participants => _participantProvider.participants;
  int get participantsLeft {
    return _participantProvider.participants.where((participant) {
      // Check if the participant has stamps for all segments
      final stampedSegments =
          participant.stamps.map((s) => s.segment.toLowerCase()).toSet();
      final requiredSegments = segments.map((s) => s.toLowerCase()).toSet();
      return !requiredSegments.every(stampedSegments.contains);
    }).length;
  }

  bool get isRaceActive => _isRaceActive;
  String get elapsedTime => _elapsedTime;

  bool get isTimerReset => _elapsedTime == "00:00:00";

  Future<void> fetchRaceData() async {
    try {
      await _participantProvider.fetchParticipants();
      await _stampProvider.getStamps();
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching race data: $e");
    }
  }

  void _startTimer() {
    logger.i("Starting race timer");
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_raceStartTime != null) {
        final now = DateTime.now();
        final difference = now.difference(_raceStartTime!);
        final hours = difference.inHours.toString().padLeft(2, '0');
        final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
        _elapsedTime = "$hours:$minutes:$seconds";
        notifyListeners();
      }
    });
  }

  Future<void> startRace() async {
    _raceStartTime ??= DateTime.now();
    if (!_isRaceActive) {
      _isRaceActive = true;
      _raceStartTime = DateTime.now();
      _raceEndTime = null;

      _startTimer();

      try {
        for (var participant in participants) {
          // Assigned Start time and Status to participant
          participant.status = ParticipantStatus.ongoing;
          participant.startTime = _raceStartTime!;
          await _dbRef.child('participants/${participant.bib}').update({
            'status': 'ongoing',
            'start_time': _raceStartTime!.toIso8601String(),
          });
        }

        await _dbRef.child('raceStatus').update({
          'status': 'active',
          'startTime': _raceStartTime!.toIso8601String(),
          'finishTime': null,
        });
      } catch (e) {
        logger.e("Error starting race: $e");
      }

      notifyListeners();
    }
  }

  void _calculateElapsedTime() {
    if (_raceStartTime == null) {
      _elapsedTime = "00:00:00";
      return;
    }

    final now =
        _isRaceActive ? DateTime.now() : (_raceEndTime ?? DateTime.now());
    final difference = now.difference(_raceStartTime!);
    final hours = difference.inHours.toString().padLeft(2, '0');
    final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    _elapsedTime = "$hours:$minutes:$seconds";
  }

  Future<void> finishRace() async {
    if (_isRaceActive) {
      _isRaceActive = false;
      _raceEndTime = DateTime.now();
      _timer?.cancel();
      _timer = null;
      _calculateElapsedTime();

      try {
        await _dbRef.child('raceStatus').update({
          'status': 'finished',
          'finishTime': _raceEndTime!.toIso8601String(),
          'participantsLeft': 0,
        });

        for (var participant in participants) {
          if (participant.status != ParticipantStatus.finished) {
            participant.status = ParticipantStatus.finished;
            await _dbRef.child('participants/${participant.bib}').update({
              'status': 'finished',
              'finish_time': _raceEndTime!.toIso8601String(),
            });
          }
        }
      } catch (e) {
        logger.e("Error finishing race: $e");
      }
      notifyListeners();
    }
  }

  Future<void> resetRace() async {
    _isRaceActive = false;
    _raceStartTime = null;
    _raceEndTime = null;
    _elapsedTime = "00:00:00";

    await _dbRef.child('raceStatus').set({
      'status': 'not_started',
      'startTime': null,
      'finishTime': null,
      'participantsLeft': participants.where((p) => p.stamps.isEmpty).length,
    });

    for (var participant in participants) {
      participant.status = ParticipantStatus.not_started;
      participant.startTime = null;
      await _dbRef.child('participants/${participant.bib}').update({
        'status': 'not_started',
        'start_time': null,
        'finish_time': null,
        'stamps': {},
      });
    }
    notifyListeners();
  }
}
