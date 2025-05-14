import 'package:race_tracker/model/stamp.dart';

class StampDto {
  static Stamp fromJson(Map<String, dynamic> json) {
    return Stamp(
      bib: json['bib'] as int,
      segment: json['segment'] as String,
      time: DateTime.parse(json['time'] as String),
    );
  }
  static Map<String, dynamic> toJson(Stamp stamp) {
    return {
      'bib': stamp.bib,
      'segment': stamp.segment,
      'time': stamp.time.toIso8601String(),
    };
  }
  static List<Stamp> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}