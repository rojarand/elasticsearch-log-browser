import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/utlis/pair.dart';

class Repository {
  Future<Map<String, String>> load() async {
    return null;
  }

  Future<void> save(Map<String, String> data) async {
    return null;
  }
}

class DefaultRepository implements Repository {
  final _storage = FlutterSecureStorage();

  Future<Map<String, String>> load() async {
    return _storage.readAll();
  }

  Future<void> save(Map<String, String> data) async {
    return data.forEach((key, value) async {
      await _storage.write(key: key, value: value);
    });
  }
}

class AppSettingsRepository {
  String _prefix;
  Repository _repository;

  AppSettingsRepository() {
    _prefix = "_";
    _repository = makeRepository();
  }

  AppSettingsRepository.withCustomPrefix(String prefix) {
    this._prefix = prefix;
    _repository = makeRepository();
  }

  Repository makeRepository() {
    return DefaultRepository();
  }

  Future<AppSettings> load() async {
    Map<String, String> kv = fromPairs(asPairs(await _repository.load())
            .where((element) => element.k.startsWith(_prefix)))
        .map((key, value) =>
            MapEntry(key.replaceRange(0, _prefix.length, ""), value));
    return AppSettings(kv);
  }

  Future<void> save(AppSettings appSettings) async {
    return _repository.save(
        appSettings.kv.map((key, value) => MapEntry(_prefix + key, value)));
  }
}
