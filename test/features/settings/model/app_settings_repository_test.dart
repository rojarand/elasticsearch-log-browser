import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings_repository.dart';
import "package:test/test.dart";

class FakeAppRepository implements Repository {
  Map<String, String> data = Map<String, String>();

  @override
  Future<Map<String, String>> load() async {
    return data;
  }

  @override
  Future<void> save(Map<String, String> data) async {
    this.data = data;
  }
}

class AppSettingsRepositoryStub extends AppSettingsRepository {
  AppSettingsRepositoryStub() : super.withCustomPrefix("+");

  @override
  Repository makeRepository() {
    return FakeAppRepository();
  }
}

void main() {
  test('Should load expecting settings', () async {
    //given
    AppSettingsRepositoryStub appSettingsRepository =
        AppSettingsRepositoryStub();
    AppSettings inSettings = await appSettingsRepository.load();

    //when
    AppSettings copyOfSettings =
        inSettings.copyWithNewServerUrl("http://blabla");
    appSettingsRepository.save(copyOfSettings);

    //then
    AppSettings outSettings = await appSettingsRepository.load();
    expect(outSettings.serverUrl, "http://blabla");
  });

  test('Loaded settings should be equal', () async {
    AppSettingsRepositoryStub appSettingsRepository =
        AppSettingsRepositoryStub();
    AppSettings settings1 = await appSettingsRepository.load();
    AppSettings settings2 = await appSettingsRepository.load();
    expect(settings1, equals(settings2));
  });

  test('Different settings should not be equal', () async {
    //given
    AppSettingsRepositoryStub appSettingsRepository =
        AppSettingsRepositoryStub();
    AppSettings settings = await appSettingsRepository.load();
    AppSettings settingsWithEmptyUrl = settings.copyWithNewServerUrl('');

    //when
    AppSettings settingsWithNonEmptyUrl =
        settingsWithEmptyUrl.copyWithNewServerUrl('http:....');

    //then
    expect(settingsWithEmptyUrl, isNot(equals(settingsWithNonEmptyUrl)));
  });
}
