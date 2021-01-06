import "dart:convert";

import "package:flutter/material.dart";
import 'package:elastic_log_browser/features/logbrowsing/model/es_doc_request.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_query_parameters.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/mapping.dart';
import "package:test/test.dart";

import '../../settings/model/es_mapping_request_test.dart';

EsQueryFiltering sampleQueryFiltering({SelectedSeverities selectedSeverities}) {
  return EsQueryFiltering(
      from: 1,
      size: 10,
      fromDate: DateTime.now(),
      fromTime: TimeOfDay(hour: 6, minute: 23),
      toDate: DateTime.now(),
      toTime: TimeOfDay(hour: 12, minute: 45),
      text: 'Foo',
      selectedSeverities: selectedSeverities != null
          ? selectedSeverities
          : SelectedSeverities.allDeselected());
}

class StubbedEsQueryMapping extends EsQueryMapping {
  StubbedEsQueryMapping({String severityFieldName})
      : super(_makeAppSettings(severityFieldName: severityFieldName));

  static AppSettings _makeAppSettings({String severityFieldName}) {
    AppSettings appSettings = AppSettings(Map<String, String>());
    appSettings = appSettings.copyWithNewSeverityFieldName(severityFieldName);
    Mappings mappings = Mappings(encodedMappings: SampleEncodedMapping);
    appSettings = appSettings.copyWithNewMappings(mappings);
    appSettings = appSettings.copyWithNewTimestampFieldName("timestamp");
    return appSettings;
  }
}

void main() {
  test('Should build non empty search json request', () {
    var mapping = StubbedEsQueryMapping(severityFieldName: "importance");
    var filtering = EsQueryFiltering(
        from: 1,
        size: 10,
        fromDate: DateTime.now(),
        fromTime: TimeOfDay(hour: 6, minute: 23),
        toDate: DateTime.now(),
        toTime: TimeOfDay(hour: 12, minute: 45),
        text: 'Foo',
        selectedSeverities: SelectedSeverities.allSelected());

    EsQueryParameters queryParameters = EsQueryParameters(mapping, filtering);

    final jsonRequest = buildJsonRequestBody(queryParameters);
    final stringRequest = json.encode(jsonRequest);
    print(stringRequest);
    expect(stringRequest.length > 0, true);
  });

  test(
      'When severities are selected and mapping exists then query should contain "severity" field name in json',
      () {
    //given
    var mapping = StubbedEsQueryMapping(severityFieldName: 'logType');
    SelectedSeverities selectedSeverities = SelectedSeverities.allDeselected();
    var filtering =
        sampleQueryFiltering(selectedSeverities: selectedSeverities);
    EsQueryParameters queryParameters = EsQueryParameters(mapping, filtering);

    //when
    selectedSeverities.select(severity: Severity.trace());

    //then
    final stringRequest = json.encode(buildJsonRequestBody(queryParameters));
    print(stringRequest);
    expect(stringRequest.contains('logType'), true);
  });
}
