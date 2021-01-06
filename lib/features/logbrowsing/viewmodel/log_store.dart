import 'package:elastic_log_browser/features/logbrowsing/model/log_entry.dart';
import 'package:flutter/material.dart';

class LogStore extends ChangeNotifier {
  final List<LogEntry> _logEntries = List();

  List<LogEntry> get logEntries => _logEntries;

  void removeAllLogs() {
    _logEntries.clear();
    notifyListeners();
  }

  void addAll(List<LogEntry> logs) {
    _logEntries.addAll(logs);
    notifyListeners();
  }

  LogEntry logAt(int index) {
    return _logEntries[index];
  }

  int get count => _logEntries.length;
}