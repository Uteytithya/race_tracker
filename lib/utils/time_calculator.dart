import 'package:race_tracker/model/stamp.dart';

class TimeCalculator {
  static Map<String, dynamic> calculateTimes({
    required DateTime raceStart,
    required List<Stamp> stamps,
  }) {
    List<Duration> lapDurations = [];
    if (stamps.isEmpty) {
      return {
        'lapTimes': <String>[],
        'totalTime': _formatDuration(Duration.zero),
      };
    }

    // Lap 1: from race start to first stamp
    Duration firstLap = stamps.first.time.difference(raceStart);
    lapDurations.add(firstLap);

    // Subsequent laps: difference between consecutive stamps
    for (int i = 1; i < stamps.length; i++) {
      Duration lap = stamps[i].time.difference(stamps[i - 1].time);
      lapDurations.add(lap);
    }

    // Total race time: from race start to last stamp
    Duration total = stamps.last.time.difference(raceStart);

    List<String> lapTimes = lapDurations.map((d) => _formatDuration(d)).toList();

    return {
      'lapTimes': lapTimes,
      'totalTime': _formatDuration(total),
    };
  }

  // Helper to format a duration as "hh:mm:ss.mmm"
  static String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    int milliseconds = duration.inMilliseconds % 1000;
    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}.'
           '${milliseconds.toString().padLeft(3, '0')}';
  }
}
