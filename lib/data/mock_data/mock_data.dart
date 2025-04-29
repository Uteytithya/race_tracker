import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/utils/enum.dart';

final List<Participant> mockParticipants = [
  Participant(bib: 101, name: "Alice", gender: Gender.female, age: 25),
  Participant(bib: 102,name: "Bob", gender: Gender.male, age: 30),
  Participant(bib: 103,name: "Charlie", gender: Gender.male, age: 22),
  Participant(bib: 104,name: "Diana", gender: Gender.female, age: 28),
  Participant(bib: 105,name: "Evan", gender: Gender.male, age: 35),
];

void main() {
  for (var participant in mockParticipants) {
    print(participant);
  }
}