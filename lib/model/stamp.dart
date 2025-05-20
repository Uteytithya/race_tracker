class Stamp {
  final String id;
  int? bib;
  final String segment;
  final DateTime time;

  Stamp({int? bib, required String newSegment, required DateTime newTime, String? id})
    : id = id ?? generateNextId(),
      bib = bib ?? 0,
      segment = newSegment,
      time = newTime;

  static int _idCounter = 1;

  static void incrementIdCounter() => _idCounter++;
  static void setIdCounter(int newVal) => _idCounter = newVal;

  static String generateNextId() =>
      'S-${_idCounter.toString().padLeft(3, '0')}';
}
