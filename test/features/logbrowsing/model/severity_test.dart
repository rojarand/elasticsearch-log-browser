import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import "package:test/test.dart";

void main() {
  test('Different severities should not be equal', () {
    expect(Severity.error() == Severity.warning(), false);
  });

  test('The same severities should be equal', () {
    expect(Severity.warning() == Severity.warning(), true);
  });

  test('All severities should be selected', () {
    SelectedSeverities selectedSeverities = SelectedSeverities.allSelected();
    expect(selectedSeverities.all(), equals(true));
  });

  test('All severities should not be selected', () {
    SelectedSeverities selectedSeverities = SelectedSeverities.allSelected();
    selectedSeverities.deselect(severity: Severity.fatal());
    expect(selectedSeverities.all(), equals(false));
  });

  test('All severities should be selected not one', () {
    SelectedSeverities selectedSeverities = SelectedSeverities.allSelected();
    expect(selectedSeverities.one(), equals(false));
  });

  test('One severity should be selected', () {
    SelectedSeverities selectedSeverities = SelectedSeverities.allDeselected();
    selectedSeverities.select(severity: Severity.info());
    expect(selectedSeverities.one(), equals(true));
  });
}
