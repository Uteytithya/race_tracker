import 'package:race_tracker/data/dto/stamp_dto.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

class ParticipantDTO {
  static Participant fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'] as String,
      gender: genderFromString(json['gender'] as String),
      age: json['age'] as int,
      // Convert bib from String to int
      bib: int.tryParse(json['bib'].toString()) ?? 0,
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ParticipantStatus.not_started,
      ),
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      stamps: json['stamps'] != null
          ? (json['stamps'] is Map
              ? StampDto.fromJsonList(
                  (json['stamps'] as Map).values.toList())
              : [])
          : [],
    );
  }

  static Map<String, dynamic> toJson(Participant participant) {
    return {
      'name': participant.name,
      'gender': participant.gender.name,
      'age': participant.age,
      // Convert bib from int to String
      'bib': participant.bib.toString(),
      'status': participant.status.name,
      'start_time': participant.startTime?.toIso8601String(),
      'stamps': StampDto.toJsonList(participant.stamps),
    };
  }

  static Gender genderFromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Gender.male, // Default to male if invalid
    );
  }
}