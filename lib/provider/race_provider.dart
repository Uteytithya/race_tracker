import 'package:flutter/material.dart';
import 'package:race_tracker/utils/enum.dart';

class RaceProvider extends ChangeNotifier {
  final List<String> _segments = [];
  final RaceStatus _status = RaceStatus.not_started;

}