import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

class ParticipantDTO {
  static Map<String, dynamic> toJson(Participant model) {
    return {'name': model.name, 'gender': model.gender, 'age': model.age};
  }

  static Gender genderFromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () {
        throw Exception("Invalid gender value: $value");
      },
    );
  }

  static Participant fromJson(Map<String, dynamic> json) {
    return Participant(
      bib: json['bib'],
      name: json['name'],
      gender: genderFromString(json['gender']),
      age: json['age'],
    );
  }
}
