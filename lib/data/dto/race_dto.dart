import 'package:race_tracker/model/race.dart';
import 'package:race_tracker/utils/enum.dart';

class RaceDto {
  static Map<String, dynamic> toJson(Race model) {
    return {
      'participants': model.participants,
      'startTime': model.startTime,
      'finishTime': model.finishTime,
      'participantLeft': model.participantLeft,
      'raceStatus': model.raceStatus.name,
    };
  }

  static RaceStatus raceStatusFromString(String value) {
    return RaceStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () {
        throw Exception("Invalid race status value: $value");
      },
    );
  }

  static Race fromJson(Map<String, dynamic> json) {
    return Race(
      participants: json['participants'], 
      startTime: json['startTime'].toIso8601String(),
      finishTime: json['finishTime'].toIso8601String(),
      participantLeft: json['participantLeft'],
      raceStatus: raceStatusFromString(json['raceStatus']),
    );
  }
}