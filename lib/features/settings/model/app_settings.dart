import 'package:collection/collection.dart';

import 'mapping.dart';

class AppSettings {
  Map<String, String> kv;

  AppSettings(Map<String, String> kv) {
    this.kv = kv;
  }

  @override
  bool operator ==(Object other) {
    return other != null &&
        other is AppSettings &&
        MapEquality().equals(this.kv, other.kv);
  }

  @override
  int get hashCode => kv.hashCode;

  static const String _SERVER_URL = "server_url";

  String get serverUrl => kv[_SERVER_URL];

  AppSettings copyWithNewServerUrl(String url) {
    return AppSettings(_copyWithNew(key: _SERVER_URL, value: url));
  }

  static const String _ELASTICSEARCH_INDEX = "elasticsearch_index";

  String get elasticsearchIndex => kv[_ELASTICSEARCH_INDEX];

  AppSettings copyWithNewElasticsearchIndex(String index) {
    return AppSettings(_copyWithNew(key: _ELASTICSEARCH_INDEX, value: index));
  }

  static const String _HTTP_AUTHENTICATION = "http_authentication";

  String get httpAuthentication => kv[_HTTP_AUTHENTICATION];

  AppSettings copyWithNewHttpAuthentication(String httpAuthentication) {
    return AppSettings(
        _copyWithNew(key: _HTTP_AUTHENTICATION, value: httpAuthentication));
  }

  static const String _INDEX_MAPPINGS = "index_mappings";

  Mappings get mappings => kv[_INDEX_MAPPINGS] != null
      ? Mappings(encodedMappings: kv[_INDEX_MAPPINGS])
      : null;

  AppSettings copyWithNewMappings(Mappings mappings) {
    return AppSettings(
        _copyWithNew(key: _INDEX_MAPPINGS, value: mappings.encodedMappings));
  }

  static const String _TIMESTAMP_FIELD_NAME = "timestamp_field_name";

  String get timestampFieldName => kv[_TIMESTAMP_FIELD_NAME];

  AppSettings copyWithNewTimestampFieldName(String timestampFieldName) {
    return AppSettings(
        _copyWithNew(key: _TIMESTAMP_FIELD_NAME, value: timestampFieldName));
  }

  static const String _SEVERITY_FIELD_NAME = "severity_field_name6";

  String get severityFieldName => kv[_SEVERITY_FIELD_NAME];

  AppSettings copyWithNewSeverityFieldName(String severityFieldName) {
    return AppSettings(
        _copyWithNew(key: _SEVERITY_FIELD_NAME, value: severityFieldName));
  }

  static const String _LOG_TITLE_FIELD_NAME = "log_title_field_name";

  String get logTitleFieldName => kv[_LOG_TITLE_FIELD_NAME];

  AppSettings copyWithNewLogTitleFieldName(String logTitleFieldName) {
    return AppSettings(
        _copyWithNew(key: _LOG_TITLE_FIELD_NAME, value: logTitleFieldName));
  }

  Map<String, String> _copyWithNew({String key, String value}) {
    Map<String, String> newKv = kv.map((key, value) => MapEntry(key, value));
    newKv[key] = value;
    return newKv;
  }
}
