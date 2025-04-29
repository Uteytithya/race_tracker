import 'package:race_tracker/utils/enum.dart';

class Participant {
  final int bib;
  final String name;
  final int age;
  final Gender gender;

  Participant({
    required this.bib,
    required this.name,
    required this.age,
    required this.gender,
  });

  @override
  String toString() {
    return '\nParticipant\n{\n\tname: $name,\n\tgender: ${gender.name},\n\tage: $age\n}\n';
  }
}
