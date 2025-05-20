class Race {
  final String status;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int participantsLeft;
  final List<String> segments;
  bool isOngoing = false;

  Race({
    required this.status,
    DateTime? startTime,
    int? participantsLeft,
    required finishTime,
    List<String>? segments,
  }) : startTime = startTime ?? DateTime.now(),
       finishTime = null,
       participantsLeft = participantsLeft ?? 0,
       segments = segments ?? [];

  void addSegment(String segment) {
    segments.add(segment);
  }
}
