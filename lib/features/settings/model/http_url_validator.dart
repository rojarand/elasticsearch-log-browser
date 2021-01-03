import 'package:elastic_log_browser/utlis/validators.dart';

class HttpUrlValidator {
  bool isValid(String urlCandidate) {
    return isURL(urlCandidate,
        protocols: const ['http', 'https'], requireProtocol: true);
  }
}
