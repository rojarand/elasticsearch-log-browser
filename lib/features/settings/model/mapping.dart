import 'dart:convert';

import 'package:elastic_log_browser/utlis/pair.dart';

class Mapping {
  final Map<String, dynamic> _mappingMap;

  Mapping(this._mappingMap);

  List<String> get fieldNames =>
      _mappingMap.keys.map((field) => field).toList();

  List<String> get fieldsWithDateType => _fieldNamesWith(type: 'date');

  List<String> get fieldsWithTextType => _fieldNamesWith(type: 'text');

  List<String> _fieldNamesWith({String type}) {
    return asPairs(_mappingMap)
        .where((pair) => pair.v['type'] == type) //only fields with given type
        .map((pair) => pair.k)
        .toList() //get key (field name) from pair
        .cast<String>(); //cast to List<String>
  }
}

class Mappings {
  final String encodedMappings;
  Map<String, Mapping> _mappingsCache;

  Map<String, Mapping> _mappings() {
    if (_mappingsCache != null) {
      return _mappingsCache;
    }
    _mappingsCache = _decodeMapFromString(encodedMappings);
    return _mappingsCache;
  }

  Mappings({this.encodedMappings});

  get count => _mappings().length;

  static Map<String, Mapping> _decodeMapFromString(String encodedMappings) {
    final jsonResponse = json.decode(encodedMappings);
    Map<String, Mapping> mappingMap = Map<String, Mapping>();
    jsonResponse.forEach((doc, mapping) {
      mappingMap[doc] = Mapping(mapping['mappings']['_doc']['properties']);
    });
    return mappingMap;
  }

  Mapping at({int position}) {
    return _mappings().values.elementAt(position);
  }

  Mapping newest() {
    if (_mappings().values.isNotEmpty) {
      return _mappings().values.last;
    } else {
      return null;
    }
  }
}
