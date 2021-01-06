import 'dart:async';

import 'package:elastic_log_browser/common/loading_status_change_notifier.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_request_parameters.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings_repository.dart';
import 'package:elastic_log_browser/features/settings/model/es_mapping_request.dart';
import 'package:elastic_log_browser/features/settings/model/mapping.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/setting_entry_configuration.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/settings_management_event.dart';

abstract class SettingsViewModel {
  Stream<SettingsEntryConfigurations> get settingsEntryConfig;

  Stream<SettingsManagementEvent> get settingsManagementEventStream;

  LoadingStatusChangeNotifier get loadingStatusChangeNotifier;

  void dispose();

  void loadSettings() {}

  Future<bool> canWindowBeDismissed();
}

class SettingsViewModelImpl implements SettingsViewModel {
  var _appSettingsController = StreamController<AppSettings>.broadcast();
  var _settingsManagementEventStreamController =
      StreamController<SettingsManagementEvent>.broadcast();

  final LoadingStatusChangeNotifier _loadingStatusChangeNotifier =
      LoadingStatusChangeNotifier();

  LoadingStatusChangeNotifier get loadingStatusChangeNotifier =>
      _loadingStatusChangeNotifier;

  @override
  Stream<SettingsEntryConfigurations> get settingsEntryConfig =>
      _appSettingsController.stream
          .map((appSettings) => makeSettingsEntryConfigurations(appSettings));

  @override
  Stream<SettingsManagementEvent> get settingsManagementEventStream =>
      _settingsManagementEventStreamController.stream;

  AppSettingsRepository get _repo => AppSettingsRepository();

  @override
  void dispose() {
    _appSettingsController.close();
    _settingsManagementEventStreamController.close();
  }

  Future<void> loadSettings() async {
    _broadcastAppSettings(await _repo.load());
  }

  Future<AppSettings> _load() async {
    return _repo.load();
  }

  Future<void> _save(AppSettings appSettings) async {
    await _repo.save(appSettings);
    _broadcastAppSettings(appSettings);
  }

  void _broadcastAppSettings(AppSettings appSettings) {
    _appSettingsController.sink.add(appSettings);
  }

  SettingsEntryConfigurations makeSettingsEntryConfigurations(
      AppSettings appSettings) {
    SettingsEntryConfigurations configEntries = SettingsEntryConfigurations();

    SettingsEntryConfiguration appVersion = createAppVersion(appSettings);
    if (appVersion != null) {
      configEntries.add(appVersion);
    }

    SettingsEntryConfiguration serverAddressConfig =
        _serverAddressEntryConfig(appSettings);
    if (serverAddressConfig != null) {
      configEntries.add(serverAddressConfig);
    }

    SettingsEntryConfiguration esIndexConfig = _esIndexEntryConfig(appSettings);
    if (esIndexConfig != null) {
      configEntries.add(esIndexConfig);
    }

    SettingsEntryConfiguration timestampConfig =
    _timestampEntryConfig(appSettings);
    if (timestampConfig != null) {
      configEntries.add(timestampConfig);
    }

    SettingsEntryConfiguration httpAuthConfig =
        _httpAuthEntryConfig(appSettings);
    if (httpAuthConfig != null) {
      configEntries.add(httpAuthConfig);
    }

    SettingsEntryConfiguration severityConfig =
        _severityEntryConfig(appSettings);
    if (severityConfig != null) {
      configEntries.add(severityConfig);
    }

    SettingsEntryConfiguration logEntryTitleConfig =
        _logTitleFieldConfiguration(appSettings);
    if (logEntryTitleConfig != null) {
      configEntries.add(logEntryTitleConfig);
    }
    return configEntries;
  }

  SettingsEntryConfiguration _serverAddressEntryConfig(
      AppSettings appSettings) {
    return createSeverAddressEntryConfiguration(
        appSettings: appSettings,
        serverAddressChanged: (String serverAddress) async {
          _tryFetchAndProcessMappings(await _saveServerUrl(serverAddress));
        });
  }

  Future<AppSettings> _saveServerUrl(String url) async {
    AppSettings appSettings = (await _load()).copyWithNewServerUrl(url);
    _save(appSettings);
    return appSettings;
  }

  SettingsEntryConfiguration _esIndexEntryConfig(AppSettings appSettings) {
    return createEsIndexEntryConfiguration(
        appSettings: appSettings,
        esIndexChanged: (String esIndex) async {
          _tryFetchAndProcessMappings(await _saveElasticsearchIndex(esIndex));
        });
  }

  Future<AppSettings> _saveElasticsearchIndex(String url) async {
    AppSettings appSettings =
        (await _load()).copyWithNewElasticsearchIndex(url);
    _save(appSettings);
    return appSettings;
  }

  SettingsEntryConfiguration _httpAuthEntryConfig(AppSettings appSettings) {
    return createHttpAuthEntryConfiguration(
        appSettings: appSettings,
        authChanged: (String auth) async {
          _tryFetchAndProcessMappings(await _saveHttpAuthentication(auth));
        });
  }

  SettingsEntryConfiguration _timestampEntryConfig(AppSettings appSettings) {
    return createTimestampConfiguration(
        appSettings: appSettings,
        timestampNameChanged: (String timestampFieldName) {
          _saveTimestampFieldName(timestampFieldName);
        });
  }

  Future<AppSettings> _saveHttpAuthentication(String key) async {
    AppSettings appSettings =
        (await _load()).copyWithNewHttpAuthentication(key);
    _save(appSettings);
    return appSettings;
  }

  Future<void> _saveTimestampFieldName(String timestampFieldName) async {
    AppSettings appSettings =
        (await _load()).copyWithNewTimestampFieldName(timestampFieldName);
    return _save(appSettings);
  }

  SettingsEntryConfiguration _logTitleFieldConfiguration(
      AppSettings appSettings) {
    return createLogTitleFieldConfiguration(
        appSettings: appSettings,
        titleFieldNameChanged: (String titleFieldName) {
          _saveLogTitleFieldName(titleFieldName);
        });
  }

  Future<void> _saveLogTitleFieldName(String logTitleFieldName) async {
    AppSettings appSettings =
        (await _load()).copyWithNewLogTitleFieldName(logTitleFieldName);
    return _save(appSettings);
  }

  SettingsEntryConfiguration _severityEntryConfig(AppSettings appSettings) {
    return createSeverityEntryConfiguration(
        appSettings: appSettings,
        severityNameChanged: (String severityFieldName) {
          _saveSeverityFieldName(severityFieldName);
        });
  }

  Future<void> _saveSeverityFieldName(String severityFieldName) async {
    AppSettings appSettings =
        (await _load()).copyWithNewSeverityFieldName(severityFieldName);
    return _save(appSettings);
  }

  Future<void> _tryFetchAndProcessMappings(AppSettings appSettings) async {
    if (appSettings.hasRequestParametersForGettingMappings) {
      _fetchAndProcessMapping(appSettings.requestParameters);
    }
  }

  void _fetchAndProcessMapping(EsRequestParameters requestParameters) async {
    _loadingStatusChangeNotifier.onLoadBegin();
    try {
      Mappings mappings = await EsMappingFetcher().fetch(requestParameters);
      _checkMappings(mappings);
      AppSettings appSettings = (await _load()).copyWithNewMappings(mappings);
      _save(appSettings);
    } catch (e) {
      _settingsManagementEventStreamController
          .add(FetchSampleLogFailureEvent(e));
    } finally {
      _loadingStatusChangeNotifier.onLoadEnd();
    }
  }

  void _checkMappings(Mappings mappings) {
    //Try obtain newest to die fast if it is not available.
    mappings.newest();
  }

  @override
  Future<bool> canWindowBeDismissed() async{
    return (await _load()).hasRequestParametersForGettingDocuments;
  }
}
