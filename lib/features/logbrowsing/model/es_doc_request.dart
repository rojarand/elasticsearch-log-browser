import "dart:convert";

import 'package:elastic_log_browser/utlis/string_utils.dart';
import "package:http/http.dart" as http;

import 'es_query_parameters.dart';
import 'es_request_parameters.dart';
import 'log_entry.dart';

class NotHttpStatus200ResponseException implements Exception {
  final http.Response response;

  NotHttpStatus200ResponseException({this.response});
}

Future<List<LogEntry>> fetchLogs(
    {EsRequestParameters requestParameters,
    EsQueryParameters queryParameters}) async {
  Map<String, String> headers = Map<String, String>();
  headers["Content-Type"] = "application/json";
  if (!nullOrEmpty(requestParameters.httpAuthentication)) {
    /*
    Authorization: <type> <credentials>
    Proxy-Authorization: <type> <credentials>
    */
    headers["Authorization"] = "Basic " +
        utf8.fuse(base64).encode(requestParameters.httpAuthentication);
  }
  final response = await http.post(requestParameters.searchUrl,
      headers: headers, body: buildStringRequestBody(queryParameters));

  if (response.statusCode == 200) {
    final List<LogEntry> newlogEntries = LogEntry.parse(response.body);
    return newlogEntries;
  } else {
    throw NotHttpStatus200ResponseException(response: response);
  }
}

String buildStringRequestBody(EsQueryParameters params) {
  var jsonRequest = buildJsonRequestBody(params);
  var bodyRequest = json.encode(jsonRequest);
  return bodyRequest;
}

Map<String, dynamic> buildJsonRequestBody(EsQueryParameters queryParameters) {
  List<dynamic> mustConditions = [];
  EsQueryFiltering params = queryParameters.filtering;

  if (queryParameters.filterBySeverity) {
    var textQuery = {};
    textQuery["query"] = queryParameters.joinSelectedSeverities(
        separator: '|' /*| signifies OR operation*/);
    textQuery["fields"] = [queryParameters.severityFieldName];
    var containsTextCondition = {};
    containsTextCondition["simple_query_string"] = textQuery;
    mustConditions.add(containsTextCondition);
  }

  if (queryParameters.filterByText) {
    var textQuery = {};
    textQuery["query"] = queryParameters.text;
    textQuery["fields"] = queryParameters.textFields;
    var containsTextCondition = {};
    containsTextCondition["simple_query_string"] = textQuery;
    mustConditions.add(containsTextCondition);
  }

  var timestampCondition = {};
  var dateConditions = {};

  if (queryParameters.filterByDateFrom) {
    dateConditions["gte"] = queryParameters.formattedDateFrom;
  }

  if (queryParameters.filterByDateTo) {
    dateConditions["lt"] = queryParameters.formattedDateTo;
  }

  var queryBoolConditions = {};
  queryBoolConditions["must"] = mustConditions;

  if (dateConditions.length > 0) {
    timestampCondition[queryParameters.timestampFieldName] = dateConditions;
    queryBoolConditions["filter"] = {"range": timestampCondition};
  }

  var jsonRequest = {
    "from": params.from,
    "size": params.size,
    "query": {"bool": queryBoolConditions},
    "sort": [
      {
        queryParameters.timestampFieldName: {"order": "asc"}
      }
    ]
  };
  return jsonRequest;
}
