class Stamp {
  final String id;
  int? bib;
  final String segment;
  final DateTime time;

  Stamp({int? bib, required String segment, required DateTime time, String? id})
    : id = id ?? generateNextId(),
      bib = bib ?? 0,
      segment = segment ?? '',
      time = time ?? DateTime.now();

  static int _idCounter = 1;

  static void incrementIdCounter() => _idCounter++;
  static void setIdCounter(int newVal) => _idCounter = newVal;

  static String generateNextId() =>
      'S-${_idCounter.toString().padLeft(3, '0')}';
}
