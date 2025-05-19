import 'package:flutter/material.dart';

class AppIcon {
  static IconData getIconForSegment(String segment) {
    switch (segment.toLowerCase()) {
      case 'run':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
      case 'swim':
        return Icons.pool;
      default:
        return Icons.timer;
    }
  }
}