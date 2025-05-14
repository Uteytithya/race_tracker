import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

class Race {
  final List<Participant> participants;
  final DateTime startTime;
  final DateTime finishTime;
  RaceStatus raceStatus;
  int participantLeft;

  Race({
    required this.participants,
    required this.startTime,
    required this.finishTime,
    RaceStatus? raceStatus,
    int? participantLeft,
  }) : raceStatus = raceStatus ?? RaceStatus.not_started,
       participantLeft = participantLeft ?? 0;
}