import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/utils/time_calculator.dart';

class Participant {
  final int bib;
  final String name;
  final int age;
  final Gender gender;
  final List<Stamp> stamps;
  DateTime? startTime;
  ParticipantStatus status;

  Participant({
    int? bib,
    required this.name,
    required this.age,
    required this.gender,
    List<Stamp>? stamps,
    ParticipantStatus? status,
    DateTime? startTime,
  }) : bib = bib ?? generateBib(),
       stamps = stamps ?? [],
       status = status ?? ParticipantStatus.not_started,
       startTime = startTime ?? DateTime.now() {
    if (name.isEmpty) {
      throw ArgumentError('Name cannot be empty');
    }
    if (age < 0) {
      throw ArgumentError('Age cannot be negative');
    }
  }

  void addStamp(Stamp stamp) {
    if (stamps.any((s) => s.segment == stamp.segment)) {
      throw ArgumentError('Stamp for this segment already exists');
    }
    stamps.add(stamp);
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

  static void incrementBibCounter() {
    _bibCounter++;
  }

  String getParticipantTime(Participant participant, String selectedSegment) {
    try {
      if (selectedSegment == 'Overall') {
        return TimeCalculator.calculateTimes(
          raceStart: participant.startTime!,
          stamps: participant.stamps,
        )['totalTime'];
      } else {
        final segmentStamps =
            participant.stamps
                .where(
                  (s) =>
                      s.segment.toLowerCase() == selectedSegment.toLowerCase(),
                )
                .toList();

        if (segmentStamps.isNotEmpty) {
          return TimeCalculator.calculateSegmentTime(
            participant.startTime!,
            segmentStamps.first.time,
          );
        }
        return "N/A";
      }
    } catch (e) {
      throw Exception('Error getting time for ${participant.name}: $e');
    }
  }
}
