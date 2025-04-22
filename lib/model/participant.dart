import 'package:race_tracker/utils/enum.dart';

class Participant{
  String name;
  Gender gender;
  int age;

  Participant({required this.name, required this.gender, required this.age});

  @override
  String toString() {
    return '\nParticipant\n{\n\tname: $name,\n\tgender: ${gender.name},\n\tage: $age\n}\n';
  }
}