import 'package:collection/collection.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/es_request_parameters.dart';
import 'package:elastic_log_browser/features/settings/model/es_mapping_request.dart';
import 'package:elastic_log_browser/features/settings/model/mapping.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  Future<Mapping> defaultMapping() async {
    Response fakeResponse = Response(SampleEncodedMapping, 200);
    EsMappingFetcher mappingFetcher = FakeResponseMappingFetcher(fakeResponse);
    Mappings mappings = await mappingFetcher.fetch(fakeRequestParameters);
    return mappings.newest();
  }

  test('Should parse valid response', () async {
    //when
    Mappings mappings = Mappings(encodedMappings: SampleEncodedMapping);
    //then
    expect(mappings.count, 2);
  });

  test('Should contain expected number of fields', () async {
    //when
    Mappings mappings = Mappings(encodedMappings: SampleEncodedMapping);
    //then
    expect(mappings.at(position: 0).fieldNames.length, 4);
  });

  test('Default mapping should contain expected fields', () async {
    Mapping mapping = await defaultMapping();
    bool equals = ListEquality().equals(
        mapping.fieldNames, ["@timestamp", "message", "severity", "tags"]);
    expect(equals, true);
  });

  test('Default mapping should contain one date field named "@timestamp"',
      () async {
    Mapping mapping = await defaultMapping();
    List<String> dateFieldNames = mapping.fieldsWithDateType;
    expect(dateFieldNames.length, 1);
    expect(dateFieldNames[0], "@timestamp");
  });
}

const EsRequestParameters fakeRequestParameters = EsRequestParameters(
    serverUrl: "", elasticsearchIndex: "", httpAuthentication: "");

class FakeResponseMappingFetcher extends EsMappingFetcher {
  final Response _response;

  FakeResponseMappingFetcher(this._response);

  @override
  Future<Response> fetchResponse(EsRequestParameters requestParameters) async {
    return _response;
  }
}

const String SampleEncodedMapping = '''
{
   "doc1":{
      "mappings":{
         "_doc":{
            "properties":{
               "@timestamp":{
                  "type":"date"
               },
               "severity":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               },
               "message":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               },
               "tags":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               }
            }
         }
      }
   },
   "doc2":{
      "mappings":{
         "_doc":{
            "properties":{
               "@timestamp":{
                  "type":"date"
               },
               "message":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               },
               "severity":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               },
               "tags":{
                  "type":"text",
                  "fields":{
                     "keyword":{
                        "type":"keyword",
                        "ignore_above":256
                     }
                  }
               }
            }
         }
      }
   }
}
''';
