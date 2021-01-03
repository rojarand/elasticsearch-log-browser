import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/loading_status_change_notifier.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_query_parameters.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_request_parameters.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/presentable_log_entry.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import 'package:elastic_log_browser/features/logbrowsing/view/filter/filter_widget.dart';
import 'package:elastic_log_browser/features/logbrowsing/viewmodel/log_browsing_event.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings_repository.dart';
import 'package:elastic_log_browser/utlis/range.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

import '../model/es_doc_request.dart';
import '../model/log_entry.dart';

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

class LogsViewModel extends ChangeNotifier {
  FilterWidgetParameters filterWidgetParameters;

  final LogStore _logs = LogStore();

  LogStore get logs => _logs;
  AppSettings _appSettings;

  bool _isLoadingInProgress = false;

  final LoadingStatusChangeNotifier _loadingStatusChangeNotifier =
      LoadingStatusChangeNotifier();

  LoadingStatusChangeNotifier get loadingStatusChangeNotifier =>
      _loadingStatusChangeNotifier;

  final StreamController _logBrowsingEventNotifier =
      StreamController<LogBrowsingEvent>();

  StreamController get logBrowsingEventNotifier => _logBrowsingEventNotifier;

  int get numberOfLogs => _logs.count;

  final StreamController _filterWidgetParametersController =
      StreamController<FilterWidgetParameters>();

  Stream<FilterWidgetParameters> get filterWidgetParametersStream =>
      _filterWidgetParametersController.stream;

  LogsViewModel() {
    _initFilterParameters();
  }

  Future<void> _initFilterParameters() async {
    filterWidgetParameters = _defaultFilterParameters();
    AppSettings appSettings = await AppSettingsRepository().load();
    filterWidgetParameters.severityVisible =
        !nullOrEmpty(appSettings.severityFieldName);
    _filterWidgetParametersController.add(filterWidgetParameters);
  }

  @override
  void dispose() {
    super.dispose();
    _logBrowsingEventNotifier.sink.close();
    _filterWidgetParametersController.sink.close();
  }

  void removeAllLogs() {
    _logs.removeAllLogs();
  }

  PresentableLogEntry logAt(int index) {
    return _logs.logAt(index).asPresentable(_appSettings);
  }

  void filterParamsChanged(FilterWidgetParameters newFilterSettings) {
    filterWidgetParameters = newFilterSettings;
  }

  static FilterWidgetParameters _defaultFilterParameters() {
    final DateTime today = new DateTime.now();
    final DateTime yesterday = today.subtract(Duration(hours: 24));

    return FilterWidgetParameters(
        fromDateTimeActive: false,
        fromDate: yesterday,
        fromTime: TimeOfDay(hour: yesterday.hour, minute: yesterday.minute),
        toDateTimeActive: false,
        toDate: today,
        toTime: TimeOfDay(hour: today.hour, minute: today.minute),
        selectedSeverities: SelectedSeverities.allDeselected(),
        severityVisible: false);
  }

  void load() async {
   if(_isLoadingInProgress){
     return;
   }
   _isLoadingInProgress = true;
   await _load();
   _isLoadingInProgress = false;
  }

  Future<void> _load() async {
    AppSettings newAppSettings = await AppSettingsRepository().load();
    try {
      if (!newAppSettings.hasRequestParametersForGettingDocuments) {
        _logBrowsingEventNotifier.add(SettingsNeededEvent());
        return;
      }
      await _doLoad(newAppSettings);
    } finally {
      _appSettings = newAppSettings;
    }
  }

  void onSettingsMayHaveChanged() async {
    AppSettings newAppSettings = await AppSettingsRepository().load();
    bool actualSeverityVisibility = filterWidgetParameters.severityVisible;
    bool expectedSeverityVisibility =
        !nullOrEmpty(newAppSettings.severityFieldName);
    if (actualSeverityVisibility != expectedSeverityVisibility) {
      filterWidgetParameters.severityVisible = expectedSeverityVisibility;
      _filterWidgetParametersController.add(filterWidgetParameters);
    }
    _reloadIfSettingsChanged(newAppSettings);
  }

  void _reloadIfSettingsChanged(AppSettings newAppSettings) async {
    try {
      if (!newAppSettings.hasRequestParametersForGettingDocuments) {
        _logBrowsingEventNotifier.add(SettingsNeededEvent());
      } else if (_paramsForLoadingChanged(newAppSettings)) {
        _logs.removeAllLogs();
        _doLoad(newAppSettings);
      }
    } finally {
      _appSettings = newAppSettings;
    }
  }

  bool _paramsForLoadingChanged(AppSettings newAppSettings) {
    if (_appSettings == null) {
      return false;
    }
    return _appSettings != newAppSettings;
  }

  Future<void> _doLoad(AppSettings appSettings) async {
    _loadingStatusChangeNotifier.onLoadBegin();
    try {
      EsQueryParameters queryParameters =
          _makeQueryParameters(appSettings.queryMapping);
      List<LogEntry> logs = await fetchLogs(
          requestParameters: appSettings.requestParameters,
          queryParameters: queryParameters);
      _logs.addAll(logs);
    } catch (e) {
      _logBrowsingEventNotifier.add(FetchLogsFailureEvent(e));
    } finally {
      _loadingStatusChangeNotifier.onLoadEnd();
    }
  }

  EsQueryParameters _makeQueryParameters(EsQueryMapping queryMapping) {
    Range range = Range(begin: this.numberOfLogs, length: 10);
    EsQueryFiltering queryFiltering = _makeQueryFiltering(filterWidgetParameters, range);
    return EsQueryParameters(queryMapping, queryFiltering);
  }

  static EsQueryFiltering _makeQueryFiltering(
      FilterWidgetParameters filterWidgetParameters, Range range) {
    DateTime fromDate, toDate;
    TimeOfDay fromTime, toTime;
    if (filterWidgetParameters.fromDateTimeActive) {
      fromDate = filterWidgetParameters.fromDate;
      fromTime = filterWidgetParameters.fromTime;
    }
    if (filterWidgetParameters.toDateTimeActive) {
      toDate = filterWidgetParameters.toDate;
      toTime = filterWidgetParameters.toTime;
    }
    return EsQueryFiltering(
        from: range.begin,
        size: range.length,
        fromDate: fromDate,
        fromTime: fromTime,
        toDate: toDate,
        toTime: toTime,
        text: filterWidgetParameters.text,
        selectedSeverities: filterWidgetParameters.selectedSeverities);
  }
}
