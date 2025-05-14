import 'package:race_tracker/model/race.dart';
import 'package:race_tracker/utils/enum.dart';

class RaceDto {
  static Map<String, dynamic> toJson(Race race) {
    return {
      "status": race.status,
      "startTime": race.startTime,
      "finishTime": race.finishTime,
      "participantsLeft": race.participantsLeft,
    };
  }

  static Race fromJson(Map<String, dynamic> raceStatus, List<String> segments) {
    return Race(
      status: raceStatus['status'] ?? 'not_started',
      startTime: raceStatus['startTime'] ?? '',
      finishTime: raceStatus['finishTime'] ?? '',
      participantsLeft: raceStatus['participantsLeft'] ?? 0,
      segments: segments,
    );
  }

  static List<String> segmentsFromJson(List<dynamic> segments) {
    return segments.map((segment) => segment.toString()).toList();
  }
  static List<String> segmentsToJson(List<String> segments) {
    return segments.map((segment) => segment.toString()).toList();
  }

  static RaceStatus statusFromJson(String status) {
    switch (status) {
      case 'not_started':
        return RaceStatus.not_started;
      case 'ongoing':
        return RaceStatus.ongoing;
      case 'finished':
        return RaceStatus.finished;
      default:
        return RaceStatus.not_started;
    }
  }
}