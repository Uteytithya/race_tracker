import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

final List<Participant> mockParticipants = [
  Participant(name: "Alice", gender: Gender.female, age: 25),
  Participant(name: "Bob", gender: Gender.male, age: 30),
  Participant(name: "Charlie", gender: Gender.male, age: 22),
  Participant(name: "Diana", gender: Gender.female, age: 28),
  Participant(name: "Evan", gender: Gender.male, age: 35),
];

void main() {
  for (var participant in mockParticipants) {
    print(participant);
  }
}