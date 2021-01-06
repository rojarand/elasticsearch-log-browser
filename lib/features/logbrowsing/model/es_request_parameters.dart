import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/elasticsearch_index_validator.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

import '../../settings/model/http_url_validator.dart';

class EsRequestParameters {
  final String serverUrl;
  final String elasticsearchIndex;
  final String httpAuthentication;

  const EsRequestParameters(
      {this.serverUrl, this.elasticsearchIndex, this.httpAuthentication});

  String get searchUrl => serverUrl + '/' + elasticsearchIndex + '/_search';

  String get mappingUrl => serverUrl + '/' + elasticsearchIndex + '/_mapping';
}

bool isAddressValid(String addressCandidate) {
  return new HttpUrlValidator().isValid(addressCandidate);
}

extension RequestSettingsFunctionality on AppSettings {
  EsRequestParameters get requestParameters => EsRequestParameters(
      serverUrl: this.serverUrl,
      elasticsearchIndex: this.elasticsearchIndex,
      httpAuthentication: this.httpAuthentication);

  bool get hasRequestParametersForGettingMappings =>
      HttpUrlValidator().isValid(serverUrl) &&
      ElasticsearchIndexValidator().isValid(elasticsearchIndex);

  bool get hasRequestParametersForGettingDocuments => 
      HttpUrlValidator().isValid(serverUrl) && 
          ElasticsearchIndexValidator().isValid(elasticsearchIndex) && 
          !nullOrEmpty(this.timestampFieldName);
}
