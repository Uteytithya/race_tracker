class Race {
  final String status;
  final String startTime;
  final String finishTime;
  final int participantsLeft;
  final List<String> segments;

  Race({
    required this.status,
    required this.startTime,
    required this.finishTime,
    required this.participantsLeft,
    required this.segments,
  });
}