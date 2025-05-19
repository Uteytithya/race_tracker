
import 'package:flutter/material.dart';
import 'package:race_tracker/widget/app_custom_toast.dart';
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


