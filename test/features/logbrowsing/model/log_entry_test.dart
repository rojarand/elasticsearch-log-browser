import 'package:elastic_log_browser/features/logbrowsing/model/log_entry.dart';
import 'package:elastic_log_browser/utlis/date_time.dart';
import "package:test/test.dart";

void main() {
  test('Should parse date', () {
    final date = parseDatetime("2019-10-05T06:20:00.000+0200");
    print(date.toIso8601String());
    print(date.toString());
    print(date.toLocal().toString());
  });

  test('Should parse "LogEntries" from json string', () {
    final responseBody = r"""
    {"took":256,"timed_out":false,"_shards":{"total":90,"successful":85,"skipped":0,"failed":5,"failures":[{"shard":0,"index":"test-logs-v1-1978.10.15","node":"T8UYEm2tQsKvhxRYGJspag","reason":{"type":"query_shard_exception","reason":"No mapping found for [@timestamp] in order to sort on","index_uuid":"U7GN-m1RTyiRE56g9KrMEA","index":"test-logs-v1-1978.10.15"}}]},"hits":{"total":7363,"max_score":null,
    "hits":[{"_index":"test-logs-v1-2019.10.05","_type":"_doc","_id":"qxmvmm0BkzHcJTY55hWA","_score":null,
      "_source":{"severity":"error","@timestamp":"2019-10-05T06:51:20.605Z","method":"post-sign-in","sourceType":"user","message":"User with email not found."},"sort":[1570258280605]}]}}
    """;
    final logEntries = LogEntry.parse(responseBody);
    expect(logEntries.length, 1);
  });
}
