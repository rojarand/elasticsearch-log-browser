import 'package:elastic_log_browser/utlis/string_utils.dart';

class ElasticsearchIndexValidator {
  bool isValid(String elasticsearchIndexCandidate) {
    return !nullOrEmpty(elasticsearchIndexCandidate);
  }
}
