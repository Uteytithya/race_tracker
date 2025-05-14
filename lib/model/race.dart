class Race {
  final String status;
  final DateTime startTime;
  DateTime? finishTime;
  final int participantsLeft;
  final List<String> segments;

  Race({
    required this.status,
    DateTime? startTime,
    int? participantsLeft,
    required this.segments,
    required finishTime,
  }) : startTime = startTime ?? DateTime.now(),
       finishTime = null,
       participantsLeft = participantsLeft ?? 0;
}
