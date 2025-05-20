import 'package:race_tracker/model/stamp.dart';

class TimeCalculator {
  static Map<String, dynamic> calculateTimes({
    required DateTime raceStart,
    required List<Stamp> stamps,
  }) {
    if (stamps.isEmpty) {
      return {
        'lapTimes': <String>[],
        'totalTime': _formatDuration(Duration.zero),
      };
    }

    // Ensure stamps are sorted chronologically.
    stamps.sort((a, b) => a.time.compareTo(b.time));

    List<Duration> lapDurations = [];

    // Lap 1: from race start to first stamp.
    Duration firstLap = stamps.first.time.difference(raceStart);
    lapDurations.add(firstLap);

    // Subsequent laps: difference between consecutive stamps.
    for (int i = 1; i < stamps.length; i++) {
      Duration lap = stamps[i].time.difference(stamps[i - 1].time);
      lapDurations.add(lap);
    }

    // Total race time: from race start to last stamp.
    Duration total = stamps.last.time.difference(raceStart);

    List<String> lapTimes =
        lapDurations.map((d) => _formatDuration(d)).toList();

    return {'lapTimes': lapTimes, 'totalTime': _formatDuration(total)};
  }

  // Helper to format a duration as "hh:mm:ss.mmm"
  static String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    int milliseconds = duration.inMilliseconds % 1000;
    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}mn '
        '${seconds.toString().padLeft(2, '0')}s '
        '${milliseconds.toString().padLeft(3, '0')}ms';
  }

  static int compareTimeStrings(String timeA, String timeB) {
    try {
      final partsA = timeA.split(':');
      final partsB = timeB.split(':');
      
      // Compare hours
      final hoursA = int.tryParse(partsA[0]) ?? 0;
      final hoursB = int.tryParse(partsB[0]) ?? 0;
      if (hoursA != hoursB) return hoursA.compareTo(hoursB);
      
      // Compare minutes
      final minutesA = int.tryParse(partsA[1]) ?? 0;
      final minutesB = int.tryParse(partsB[1]) ?? 0;
      if (minutesA != minutesB) return minutesA.compareTo(minutesB);
      
      // Compare seconds
      final secPartsA = partsA[2].split('.');
      final secPartsB = partsB[2].split('.');
      final secondsA = int.tryParse(secPartsA[0]) ?? 0;
      final secondsB = int.tryParse(secPartsB[0]) ?? 0;
      if (secondsA != secondsB) return secondsA.compareTo(secondsB);
      
      // Compare milliseconds if present
      if (secPartsA.length > 1 && secPartsB.length > 1) {
        final msA = int.tryParse(secPartsA[1]) ?? 0;
        final msB = int.tryParse(secPartsB[1]) ?? 0;
        return msA.compareTo(msB);
      }

      throw Exception('Incomparable time strings');
    } catch (e) {
      throw Exception('Error comparing times: $e');
    }
  }

  static String calculateSegmentTime(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds = ((duration.inMilliseconds % 1000) ~/ 10)
        .toString()
        .padLeft(2, '0');

    return '$hours:$minutes:$seconds.$milliseconds';
  }
}
