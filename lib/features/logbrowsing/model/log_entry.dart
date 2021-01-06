import 'dart:convert';
import 'dart:core';

class LogEntry {

  final Map<dynamic, dynamic> fields;
  Map<dynamic, dynamic> get details => fields;
  LogEntry({this.fields});

  static List<LogEntry> parse(String encodedLogEntries) {
    final jsonResponse = json.decode(encodedLogEntries);
    final hitsEntryL0 = jsonResponse["hits"];
    final hitsEntryL1 = hitsEntryL0["hits"];

    final List<LogEntry> logEntries = List();
    for (var value in hitsEntryL1) {
      var source = value["_source"];
      if(source != null){
        final logEntry = LogEntry(fields:source);
        logEntries.add(logEntry);
      }
    }
    return logEntries;
  }
}


