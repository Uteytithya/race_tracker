import 'package:race_tracker/model/stamp.dart';

class StampDto {
  static Stamp fromJson(Map<String, dynamic> json) {
    return Stamp(
      id: json['id'] as String,
      bib: json['bib'] != null ? int.tryParse(json['bib'].toString()) : null,
      segment: json['segment'] as String,
      time: DateTime.parse(json['time']),
    );
  }

  static Map<String, dynamic> toJson(Stamp stamp) {
    return {
      'id': stamp.id,
      'bib': stamp.bib?.toString(),
      'segment': stamp.segment,
      'time': stamp.time.toIso8601String(),
    };
  }

  static List<Stamp> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(Map<String, dynamic>.from(json))).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<Stamp> stamps) {
    return stamps.map((stamp) => toJson(stamp)).toList();
  }
}