import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

class ParticipantDTO {
  static Participant fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['name'] as String,
      gender: genderFromString(json['gender']),
      age: json['age'] as int,
      bib: int.tryParse(json['bib'].toString()) ?? 0,
    );
  }

  static Map<String, dynamic> toJson(Participant participant) {
    return {
      'name': participant.name,
      'gender': participant.gender,
      'age': participant.age,
      'bib': participant.bib.toString(),
    };
  }

  static Gender genderFromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () {
        throw Exception("Invalid gender value: $value");
      },
    );
  }
}
