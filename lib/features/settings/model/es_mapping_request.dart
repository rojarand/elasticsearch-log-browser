import 'dart:convert';

import 'package:elastic_log_browser/features/logbrowsing/model/es_doc_request.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_request_parameters.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

import 'mapping.dart';

class EsMappingFetcher {
  Future<Response> fetchResponse(EsRequestParameters requestParameters) async {
    Map<String, String> headers = Map<String, String>();
    headers["Content-Type"] = "application/json";
    if (!nullOrEmpty(requestParameters.httpAuthentication)) {
      headers["Authorization"] = "Basic " +
          utf8.fuse(base64).encode(requestParameters.httpAuthentication);
    }
    return http.get(requestParameters.mappingUrl, headers: headers);
  }

  Future<Mappings> fetch(EsRequestParameters requestParameters) async {
    Response response = await fetchResponse(requestParameters);
    if (response.statusCode == 200) {
      final Mappings mappings = Mappings(encodedMappings: response.body);
      return mappings;
    } else {
      throw NotHttpStatus200ResponseException(response: response);
    }
  }
}
