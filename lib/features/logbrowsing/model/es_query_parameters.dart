import 'package:flutter/material.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/utlis/date_time.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';
import 'package:intl/intl.dart';

class EsQueryFiltering {
  final int from;
  final int size;
  final SelectedSeverities selectedSeverities;
  final DateTime fromDate;
  final TimeOfDay fromTime;
  final DateTime toDate;
  final TimeOfDay toTime;
  final String text;

  EsQueryFiltering(
      {this.from,
      this.size,
      this.selectedSeverities,
      this.fromDate,
      this.fromTime,
      this.toDate,
      this.toTime,
      this.text});
}

class EsQueryMapping {
  final AppSettings _appSettings;

  EsQueryMapping(this._appSettings);

  bool get severityMapped => !nullOrEmpty(_appSettings.severityFieldName);

  get severityFieldName => _appSettings.severityFieldName;

  List<String> get textFields =>
      _appSettings.mappings.newest().fieldsWithTextType;

  String get timestampFieldName => _appSettings.timestampFieldName;
}

extension MappingFunctionality on AppSettings {
  EsQueryMapping get queryMapping => EsQueryMapping(this);
}

class EsQueryParameters {
  final EsQueryMapping mapping;
  final EsQueryFiltering filtering;

  EsQueryParameters(this.mapping, this.filtering);

  bool get filterBySeverity {
    if (!mapping.severityMapped) {
      return false;
    }
    if (filtering.selectedSeverities.all()) {
      return false;
    }
    if (!filtering.selectedSeverities.any()) {
      return false;
    }
    return true;
  }

  get severityFieldName => mapping.severityFieldName;

  bool get filterByText => !nullOrEmpty(filtering.text);

  String get text => filtering.text;

  List<String> get textFields => mapping.textFields;

  bool get filterByDateFrom =>
      filtering.fromDate != null && filtering.fromTime != null;

  String get formattedDateFrom =>
      formatDateTime(filtering.fromDate, filtering.fromTime);

  bool get filterByDateTo =>
      filtering.toDate != null && filtering.toTime != null;

  String get formattedDateTo =>
      formatDateTime(filtering.toDate, filtering.toTime);

  String get timestampFieldName => mapping.timestampFieldName;

  String joinSelectedSeverities({String separator}) {
    return filtering.selectedSeverities.joinSelected(separator: separator);
  }
}
