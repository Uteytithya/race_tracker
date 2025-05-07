import 'package:race_tracker/utils/enum.dart';

class Participant {
  final int bib;
  final String name;
  final int age;
  final Gender gender;

  Participant({
    int? bib,
    required this.name,
    required this.age,
    required this.gender,
  }) : bib = bib ?? generateBib() {
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (age < 0) {
      throw ArgumentError('Age cannot be negative');
    }
  }

  @override
  String toString() {
    return '\nParticipant\n{\n\tname: $name,\n\tgender: ${gender.name},\n\tage: $age\n}\n';
  }

  // Static counter to ensure unique bib numbers.
  static int _bibCounter = 1000;

  static int generateBib() {
    return _bibCounter++;
  }
}
