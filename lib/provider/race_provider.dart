import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/utils/enum.dart';

class RaceProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool _isRaceActive = false;
  DateTime? _raceStartTime;
  DateTime? _raceEndTime;
  List<Participant> _participants = [];
  List<String> _segments = [];
  int _participantsLeft = 0;
  String _elapsedTime = "00:00:00";
  Timer? _timer;
  final logger = Logger();

  // Getters
  bool get isRaceActive => _isRaceActive;
  DateTime? get raceStartTime => _raceStartTime;
  DateTime? get raceEndTime => _raceEndTime;
  List<Participant> get participants => _participants;
  List<String> get segments => _segments;
  int get participantsLeft => _participantsLeft;
  String get elapsedTime => _elapsedTime;

  String _elapsedTimeFormatted() {
    final duration = Duration(seconds: _elapsedSeconds ?? 0);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  int? _elapsedSeconds;

  Future<void> fetchRaceData() async {
    try {
      final snapshot = await _dbRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.value as Map;

      if (data['participants'] != null) {
        final participantsData = Map<String, dynamic>.from(
          data['participants'],
        );
        _participants =
            participantsData.entries.map((entry) {
              final participantData = Map<String, dynamic>.from(entry.value);
              return Participant(
                bib: int.parse(entry.key),
                name: participantData['name'],
                age: participantData['age'],
                gender:
                    participantData['gender'] == 'Male'
                        ? Gender.male
                        : Gender.female,
                stamps:
                    participantData['stamps'] != null
                        ? (participantData['stamps'] as Map).values.map((
                          stamp,
                        ) {
                          return Stamp(
                            id: stamp['id'],
                            bib: stamp['bib'],
                            segment: stamp['segment'],
                            time: DateTime.parse(stamp['time']),
                          );
                        }).toList()
                        : [],
                startTime:
                    participantData['start_time'] != null
                        ? DateTime.parse(participantData['start_time'])
                        : null,
                status:
                    participantData['status'] == 'finished'
                        ? ParticipantStatus.finished
                        : ParticipantStatus.not_started,
              );
            }).toList();
      }

      if (data['raceStatus'] != null) {
        final raceStatus = Map<String, dynamic>.from(data['raceStatus']);
        _isRaceActive = raceStatus['status'] == 'active';
        _raceStartTime =
            raceStatus['startTime'] != null
                ? DateTime.parse(raceStatus['startTime'])
                : null;
        _raceEndTime =
            raceStatus['finishTime'] != null
                ? DateTime.parse(raceStatus['finishTime'])
                : null;
        _participantsLeft = raceStatus['participantsLeft'] ?? 0;
      }

      if (data['segments'] != null) {
        _segments = List<String>.from(data['segments']);
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching race data: $e");
    }
  }

  // Start the timer
  void _startTimer() {
    debugPrint("Starting race timer");
    _timer?.cancel(); // Cancel any existing timer

    // Start a new timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_raceStartTime != null) {
        // Calculate elapsed time directly here
        final now = DateTime.now();
        final difference = now.difference(_raceStartTime!);

        // Format the elapsed time
        final hours = difference.inHours.toString().padLeft(2, '0');
        final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');

        _elapsedTime = "$hours:$minutes:$seconds";

        // Notify listeners to update the UI
        notifyListeners();
      }
    });
  }

  // Start the race
  Future<void> startRace() async {
    if (!_isRaceActive) {
      _isRaceActive = true;
      _raceStartTime = DateTime.now();
      _raceEndTime = null;
      _participantsLeft = _participants.length;

      // Start the timer first, before any async operations
      _startTimer();

      try {
        // Update participants to not_started status
        for (var participant in _participants) {
          participant.status = ParticipantStatus.not_started;
          participant.startTime = _raceStartTime!;
          await _dbRef.child('participants/${participant.bib}').update({
            'status': 'not_started',
            'start_time': _raceStartTime!.toIso8601String(),
          });
        }

        // Update Firebase
        await _dbRef.child('raceStatus').update({
          'status': 'active',
          'startTime': _raceStartTime!.toIso8601String(),
          'finishTime': null,
          'participantsLeft': _participantsLeft,
        });
      } catch (e) {
        debugPrint("Error starting race: $e");
      }

      notifyListeners();
    }
  }

  // Calculate elapsed time based on start time
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

  // Finish the race
  Future<void> finishRace() async {
    if (_isRaceActive) {
      // 1. Update local state first
      _isRaceActive = false;
      _raceEndTime = DateTime.now();

      // 2. Make sure to cancel the timer
      _timer?.cancel();
      _timer = null;

      // 3. Calculate final elapsed time
      _calculateElapsedTime();

      try {
        // 4. Update Firebase
        await _dbRef.child('raceStatus').update({
          'status': 'finished',
          'finishTime': _raceEndTime!.toIso8601String(),
          'participantsLeft': 0,
        });

        // 5. Mark all remaining participants as finished
        for (var participant in _participants) {
          if (participant.status != ParticipantStatus.finished) {
            participant.status = ParticipantStatus.finished;
            await _dbRef.child('participants/${participant.bib}').update({
              'status': 'finished',
            });
          }
        }

        _participantsLeft = 0;
      } catch (e) {
        logger.e("Error finishing race: $e");
        // Even if Firebase update fails, keep race stopped locally
      }

      // 6. Important! Notify listeners to update UI
      notifyListeners();
    }
  }

  Future<void> addParticipant(Participant participant) async {
    _participants.add(participant);

    await _dbRef.child('participants/${participant.bib}').set({
      'name': participant.name,
      'age': participant.age,
      'gender': participant.gender == Gender.male ? 'Male' : 'Female',
      'stamps':
          participant.stamps
              .map(
                (stamp) => {
                  'id': stamp.id,
                  'bib': stamp.bib,
                  'segment': stamp.segment,
                  'time': stamp.time.toIso8601String(),
                },
              )
              .toList(),
      'start_time': participant.startTime?.toIso8601String(),
      'status':
          participant.status == ParticipantStatus.finished
              ? 'finished'
              : 'not_started',
    });

    notifyListeners();
  }

  Future<void> markParticipantFinished(int bib) async {
    final index = _participants.indexWhere((p) => p.bib == bib);
    if (index != -1) {
      _participants[index].status = ParticipantStatus.finished;

      await _dbRef.child('participants/$bib').update({
        'status': 'finished',
        'finishTime': DateTime.now().toIso8601String(),
      });

      _participantsLeft--;
      await _dbRef.child('raceStatus').update({
        'participantsLeft': _participantsLeft,
      });

      notifyListeners();
    }
  }

  Future<void> resetRace() async {
    _isRaceActive = false;
    _raceStartTime = null;
    _raceEndTime = null;
    _participantsLeft = 0;

    await _dbRef.child('raceStatus').set({
      'status': 'not_started',
      'startTime': null,
      'finishTime': null,
      'participantsLeft': 0,
    });

    // Reset participant status instead of removing them completely
    for (var participant in _participants) {
      participant.status = ParticipantStatus.not_started;
      participant.startTime = null;
      await _dbRef.child('participants/${participant.bib}').update({
        'status': 'not_started',
        'start_time': null,
      });
    }

    notifyListeners();
  }
}
