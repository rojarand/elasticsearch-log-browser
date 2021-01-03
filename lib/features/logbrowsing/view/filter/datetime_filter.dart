import "package:flutter/material.dart";

import '../../../../common/ui/colors.dart';
import 'datetime_picker.dart';

class DateTimeFilterWidget extends StatefulWidget {
  final String tag;
  final String labelText;

  final bool active;
  final DateTime date;
  final TimeOfDay time;

  final ValueChanged<bool> activityChanged;
  final ValueChanged<DateTime> dateChanged;
  final ValueChanged<TimeOfDay> timeChanged;

  const DateTimeFilterWidget(
      {this.tag,
      this.labelText,
      this.active,
      this.date,
      this.time,
      this.activityChanged,
      this.dateChanged,
      this.timeChanged});

  @override
  DateTimeFilter createState() {
    return DateTimeFilter(
        tag: tag,
        labelText: labelText,
        applyFilter: active,
        date: date,
        time: time,
        applyFilterChanged: activityChanged,
        dateChanged: dateChanged,
        timeChanged: timeChanged);
  }
}

class DateTimeFilter extends State<DateTimeFilterWidget> {
  String tag;
  String labelText;

  bool applyFilter = false;
  DateTime date;
  TimeOfDay time;

  final ValueChanged<bool> applyFilterChanged;
  final ValueChanged<DateTime> dateChanged;
  final ValueChanged<TimeOfDay> timeChanged;

  DateTimeFilter(
      {this.tag,
      this.labelText,
      this.applyFilter,
      this.date,
      this.time,
      this.applyFilterChanged,
      this.dateChanged,
      this.timeChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(flex: 1, child: _checkboxWithText(context)),
          Expanded(
            flex: 5,
            child: _dateTimePicker(),
          )
        ]);
  }

  Widget _checkbox() {
    return Checkbox(
        value: applyFilter,
        onChanged: (bool newValue) {
          setState(() {
            applyFilter = !applyFilter;
            applyFilterChanged(applyFilter);
          });
        });
  }

  Widget _checkboxWithText(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(width: 24, height: 24, child: _checkbox()),
      Text(labelText,
          style: TextStyle(fontSize: 12.0, color: _getStateColor(context)))
    ]);
  }

  Widget _dateTimePicker() {
    return DateTimePicker(
      enabled: applyFilter,
      selectedDate: date,
      selectedTime: time,
      selectDate: (DateTime date) {
        setState(() {
          this.date = date;
          dateChanged(date);
        });
      },
      selectTime: (TimeOfDay time) {
        setState(() {
          this.time = time;
          timeChanged(time);
        });
      },
    );
  }

  Color _getStateColor(BuildContext context) {
    if (applyFilter) {
      return Theme.of(context).textTheme.bodyText2.color;
    } else {
      return brighten(Theme.of(context).textTheme.bodyText2.color, 40);
    }
  }
}
