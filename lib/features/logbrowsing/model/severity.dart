import 'package:flutter/material.dart';

const String SEVERITY_TRACE = "trace";
const String SEVERITY_INFO = "info";
const String SEVERITY_DEBUG = "debug";
const String SEVERITY_WARNING = "warning";
const String SEVERITY_ERROR = "error";
const String SEVERITY_FATAL = "fatal";

class Severity {
  @override
  bool operator ==(Object other) {
    return other != null && other is Severity && this.name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  final String name;
  final Color color;

  const Severity._({this.name, this.color});

  @override
  String toString() {
    return name;
  }

  static Severity trace() {
    return new Severity._(
        name: SEVERITY_TRACE, color: Color.fromARGB(0xFF, 0x5C, 0xB8, 0x5C));
  }

  static Severity info() {
    return new Severity._(
        name: SEVERITY_INFO, color: Color.fromARGB(0xFF, 0x5C, 0xB8, 0x5C));
  }

  static Severity debug() {
    return new Severity._(
        name: SEVERITY_DEBUG, color: Color.fromARGB(0xFF, 0x5B, 0xC0, 0xDE));
  }

  static Severity warning() {
    return new Severity._(
        name: SEVERITY_WARNING, color: Color.fromARGB(0xFF, 0xF0, 0xAD, 0x4E));
  }

  static Severity error() {
    return new Severity._(
        name: SEVERITY_ERROR, color: Color.fromARGB(0xFF, 0xD9, 0x53, 0x4F));
  }

  static Severity fatal() {
    return new Severity._(
        name: SEVERITY_FATAL, color: Color.fromARGB(0xFF, 0xD9, 0x53, 0x4F));
  }

  static Severity parse(String severity) {
    if (severity == SEVERITY_TRACE) {
      return trace();
    } else if (severity == SEVERITY_INFO) {
      return info();
    } else if (severity == SEVERITY_DEBUG) {
      return debug();
    } else if (severity == SEVERITY_WARNING) {
      return warning();
    } else if (severity == SEVERITY_ERROR) {
      return error();
    } else {
      return fatal();
    }
  }
}

class SelectedSeverities {
  final Map<Severity, bool> _severitySelection = _allSelected();

  static SelectedSeverities allSelected() {
    return SelectedSeverities();
  }

  static SelectedSeverities allDeselected() {
    SelectedSeverities selectedSeverities = SelectedSeverities();
    selectedSeverities.deselectAll();
    return selectedSeverities;
  }

  static Map<Severity, bool> _allSelected() {
    return {
      Severity.trace(): true,
      Severity.info(): true,
      Severity.debug(): true,
      Severity.warning(): true,
      Severity.error(): true,
      Severity.fatal(): true,
    };
  }

  void swapSelectionFor({severity: Severity}) {
    _severitySelection[severity] = !_severitySelection[severity];
  }

  bool isSelected({severity: Severity}) {
    return _severitySelection[severity];
  }

  bool any() {
    return _severitySelection.values.any((element) => element == true);
  }

  bool all() {
    return _severitySelection.values.where((e) => e == true).length ==
        _severitySelection.length;
  }

  bool none() {
    return any() == false;
  }

  bool one() {
    return _severitySelection.values.where((e) => e == true).length == 1;
  }

  void deselectAll() {
    _severitySelection.forEach((severity, selected) {
      _severitySelection[severity] = false;
    });
  }

  void select({Severity severity}) {
    _severitySelection[severity] = true;
  }

  void deselect({Severity severity}) {
    _severitySelection[severity] = false;
  }

  String joinSelected({separator: String}) {
    String result = "";
    _severitySelection.forEach((severity, selected) {
      if (selected) {
        if (result.isNotEmpty && separator != null && !separator.isEmpty) {
          result += separator;
        }
        result += severity.name;
      }
    });
    return result;
  }
}
