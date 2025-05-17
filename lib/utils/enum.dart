
import 'package:flutter/material.dart';
import 'package:race_tracker/widget/toast.dart';
enum Gender{
  male("Male"),
  female("Female");

  final String name;
  const Gender(this.name);
}

enum RaceStatus{
  // ignore: constant_identifier_names
  not_started, ongoing, finished
}

enum ParticipantStatus{
  // ignore: constant_identifier_names
  not_started, ongoing, finished
}

void showCustomToast({
  required BuildContext context,
  required String message,
  required VoidCallback onUndo,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: CustomToast(
        message: message,
        onUndo: () {
          onUndo();
          entry.remove();
        },
        onClose: () => entry.remove(),
      ),
    ),
  );

  overlay.insert(entry);
}
