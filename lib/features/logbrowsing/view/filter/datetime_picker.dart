import "package:flutter/material.dart";
import "package:intl/intl.dart";

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: labelText,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none
            /*
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
            )
            */
            ),
        child: Row(
          children: <Widget>[
            Text(valueText),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key key,
    this.enabled,
    this.selectedDate,
    this.selectedTime,
    this.selectDate,
    this.selectTime,
  }) : super(key: key);

  final bool enabled;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2018, 8),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _InputDropdown(
            valueText: DateFormat.yMMMd().format(selectedDate),
            onPressed: () {
              if (enabled) {
                _selectDate(context);
              }
            },
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          flex: 3,
          child: _InputDropdown(
              valueText: selectedTime.format(context),
              onPressed: () {
                if (enabled) {
                  _selectTime(context);
                }
              }),
        ),
      ],
    );
  }
}
