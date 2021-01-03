import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/colors.dart';
import 'package:elastic_log_browser/features/logbrowsing/view/filter/search_text_field.dart';
import 'package:elastic_log_browser/features/logbrowsing/view/filter/severity_widget.dart';

import '../../model/severity.dart';
import 'datetime_filter.dart';

class FilterWidgetParameters {
  bool fromDateTimeActive;
  DateTime fromDate;
  TimeOfDay fromTime;
  bool toDateTimeActive;
  DateTime toDate;
  TimeOfDay toTime;
  SelectedSeverities selectedSeverities;
  bool severityVisible;
  String text;

  FilterWidgetParameters(
      {this.fromDateTimeActive,
      this.fromDate,
      this.fromTime,
      this.toDateTimeActive,
      this.toDate,
      this.toTime,
      this.selectedSeverities,
      this.severityVisible,
      this.text});
}

class FilterWidget extends StatelessWidget {
  static const double defaultMarginBetweenWidgets = 5;

  final FilterWidgetParameters filterWidgetParameters;
  final ValueChanged<FilterWidgetParameters> parametersChangedCallback;

  FilterWidget(this.filterWidgetParameters, this.parametersChangedCallback);

  @override
  Widget build(BuildContext context) {
    return _filterWidget(context);
  }

  Widget _filterWidget(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      _timeAndSeverity(context),
      SizedBox(height: defaultMarginBetweenWidgets),
      _searchField()
    ]);
  }

  Widget _timeAndSeverity(BuildContext context) {
    if (filterWidgetParameters.severityVisible) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _timeSelectionWithBorder(context)),
          SizedBox(width: defaultMarginBetweenWidgets),
          _severity()
          // Expanded(child: _severitySelection(), flex: 33),
        ],
      );
    } else {
      return Expanded(child: _timeSelectionWithBorder(context));
    }
  }

  Widget _severity() {
    return SeverityWidget(
        selectedSeverities: filterWidgetParameters.selectedSeverities,
        selectionChanged: (SelectedSeverities selectedSeverities) {
      filterWidgetParameters.selectedSeverities = selectedSeverities;
      _notifyChanged();
    });
  }

  Widget _timeSelectionWithBorder(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(0.0),
        decoration: _timeSelectionDecoration(context), //       <--- BoxDecoration here
        child: _timeSelection());
  }

  BoxDecoration _timeSelectionDecoration(BuildContext context) {
    return BoxDecoration(
      color: brighten(Theme.of(context).primaryColor, 80),
      border: Border.all(
          width: 1.5,
          color: brighten(Theme.of(context).textTheme.subtitle1.color, 80)),
      borderRadius: BorderRadius.all(
          Radius.circular(10.0) //         <--- border radius here
          ),
    );
  }

  Widget _timeSelection() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _timeFrom(),
          _timeTo(),
        ]);
  }

  Widget _timeFrom() {
    return DateTimeFilterWidget(
        tag: "",
        labelText: "From",
        active: filterWidgetParameters.fromDateTimeActive,
        date: filterWidgetParameters.fromDate,
        time: filterWidgetParameters.fromTime,
        activityChanged: (bool active) {
          filterWidgetParameters.fromDateTimeActive = active;
          _notifyChanged();
        },
        dateChanged: (DateTime dateTime) {
          filterWidgetParameters.fromDate = dateTime;
          _notifyChanged();
        },
        timeChanged: (TimeOfDay timeOfDay) {
          filterWidgetParameters.fromTime = timeOfDay;
          _notifyChanged();
        });
  }

  Widget _timeTo() {
    return DateTimeFilterWidget(
        tag: "",
        labelText: "To",
        active: filterWidgetParameters.toDateTimeActive,
        date: filterWidgetParameters.toDate,
        time: filterWidgetParameters.toTime,
        activityChanged: (bool active) {
          filterWidgetParameters.toDateTimeActive = active;
          _notifyChanged();
        },
        dateChanged: (DateTime dateTime) {
          filterWidgetParameters.toDate = dateTime;
          _notifyChanged();
        },
        timeChanged: (TimeOfDay timeOfDay) {
          filterWidgetParameters.toTime = timeOfDay;
          _notifyChanged();
        });
  }

  Widget _searchField() {
    return SearchTextFieldWidget((String text) {
      filterWidgetParameters.text = text;
      _notifyChanged();
    });
  }

  void _notifyChanged() {
    parametersChangedCallback(filterWidgetParameters);
  }
}
