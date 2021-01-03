import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';

class SeverityWidget extends StatefulWidget {
  final ValueChanged<SelectedSeverities> selectionChanged;
  final SelectedSeverities selectedSeverities;

  const SeverityWidget({@required this.selectionChanged,
    @required this.selectedSeverities})
      : super(key: const Key(""));

  @override
  State<StatefulWidget> createState() {
    return SelectedSeverity(selectionChanged: this.selectionChanged,
        selectedSeverities: this.selectedSeverities);
  }
}

class SelectedSeverity extends State<SeverityWidget> {
  final ValueChanged<SelectedSeverities> selectionChanged;
  final SelectedSeverities selectedSeverities;

  SelectedSeverity({@required this.selectionChanged,
    @required this.selectedSeverities});

  @override
  Widget build(BuildContext context) {
    /*
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      rowFor(first: Severity.trace(), second: Severity.info()),
      rowFor(first: Severity.debug(), second: Severity.warning()),
      rowFor(first: Severity.error(), second: Severity.fatal())
    ],);
     */

    return Column(
      children: [
        rowFor(first: Severity.trace(), second: Severity.info()),
        SizedBox(height: 2),
        rowFor(first: Severity.debug(), second: Severity.warning()),
        SizedBox(height: 2),
        rowFor(first: Severity.error(), second: Severity.fatal()),
      ],
    );
  }

  Widget rowFor({first: Severity, second: Severity}) {
    return Container(
        height: 30,
        child: ToggleButtons(
          children: <Widget>[
            toggleButtonWithNameOf(severity: first),
            toggleButtonWithNameOf(severity: second)
          ],
          onPressed: (int index) {
            setState(() {
              changeSelectionFor(severity: (index == 0) ? first : second);
            });
          },
          isSelected: [
            selectedSeverities.isSelected(severity: first),
            selectedSeverities.isSelected(severity: second)
          ],
        ));
  }

  Widget toggleButtonWithNameOf({severity: Severity}) {
    String name = severity.name[0].toUpperCase() + severity.name.substring(1);
    return Text(name, style: TextStyle(fontSize: 9));
  }

  void changeSelectionFor({severity: Severity}) {
    selectedSeverities.swapSelectionFor(severity: severity);
    selectionChanged(selectedSeverities);
  }
}
