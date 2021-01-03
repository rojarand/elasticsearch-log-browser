import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDateTime(DateTime date, TimeOfDay fromTime) {
  var dateTime = DateTime(
  date.year, date.month, date.day, fromTime.hour, fromTime.minute);
  print(dateTime.toIso8601String());
  final formatter = DateFormat("yyyy-MM-ddTHH:mm:ss.000");
  print(formatter.format(dateTime));
  return formatter.format(dateTime);
}

DateTime parseDatetime(String dateTimeCandidate) {
  return DateTime.parse(dateTimeCandidate);
}
