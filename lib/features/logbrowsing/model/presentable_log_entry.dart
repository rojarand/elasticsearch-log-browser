
import 'package:elastic_log_browser/features/logbrowsing/model/log_entry.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/utlis/date_time.dart';
import 'package:elastic_log_browser/utlis/pair.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

class PresentableLogEntry{
  final String title;
  final Severity severity;
  final String timestamp;
  final Map<dynamic, dynamic> detailsFields;
  const PresentableLogEntry({this.title, this.severity, this.timestamp, this.detailsFields});
}

extension LogEntryConversion on LogEntry {
  PresentableLogEntry asPresentable(AppSettings appSettings){

    String title = _sanitizedTitle(appSettings.logTitleFieldName);
    Severity severity = _sanitizedSeverity(appSettings.severityFieldName);
    String timestamp = _sanitizedTimestamp(appSettings.timestampFieldName);

    List<String> fieldsToRemove = [appSettings.logTitleFieldName,
      appSettings.severityFieldName, appSettings.timestampFieldName];
    fieldsToRemove = fieldsToRemove.where((element) => !nullOrEmpty(element)).toList();

    final Map<dynamic, dynamic> detailsFields =
    fromPairs(asPairs(fields).where((element) => !fieldsToRemove.contains(element.k)));
    return PresentableLogEntry(title: title, severity: severity,
        timestamp: timestamp, detailsFields: detailsFields);
  }

  String _sanitizedTitle(String logTitleFieldName) {
    final String altTitle = 'Select a title in the settings';
    if(nullOrEmpty(logTitleFieldName)){
      return altTitle;
    }
    String titleCandidate = fields[logTitleFieldName];
    if(!nullOrEmpty(titleCandidate)){
      return titleCandidate;
    }
    return altTitle;
  }

  Severity _sanitizedSeverity(String severityFieldName) {
    final Severity altSeverity = Severity.info();
    if(nullOrEmpty(severityFieldName)){
      return altSeverity;
    }
    String severityCandidate = fields[severityFieldName];
    if (!nullOrEmpty(severityCandidate)) {
      return Severity.parse(severityCandidate);
    }
    return altSeverity;
  }

  String _sanitizedTimestamp(String timestampFieldName) {
    if(nullOrEmpty(timestampFieldName)){
      return 'Select a timestamp in the settings';
    }
    String timestampCandidate = fields[timestampFieldName];
    if(!nullOrEmpty(timestampCandidate)){
      return parseDatetime(timestampCandidate).toString();
    }
    return 'Timestamp unavailable';
  }
}
