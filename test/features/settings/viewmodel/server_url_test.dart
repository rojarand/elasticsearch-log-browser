import 'package:elastic_log_browser/features/settings/model/http_url_validator.dart';
import 'package:test/test.dart';

void main() {
  test('Malformed url should be invalid - foo', () async {
    expect(HttpUrlValidator().isValid('foo'), false);
  });

  test('Malformed url should be invalid - http:://onet.pl', () async {
    expect(HttpUrlValidator().isValid("http:://onet.pl"), false);
  });

  test('Well formed url should be valid', () async {
    expect(HttpUrlValidator().isValid('https://foo.bar.com'), true);
  });

  test('Well formed ftp url should not be valid', () async {
    expect(HttpUrlValidator().isValid('ftp://foo.bar.com'), false);
  });
}
