import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/colors.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/presentable_log_entry.dart';
import 'package:elastic_log_browser/features/logbrowsing/model/severity.dart';
import 'package:flutter/rendering.dart';

class LogRow extends StatelessWidget {
  final PresentableLogEntry logEntry;

  LogRow({this.logEntry});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: brighten(Theme.of(context).textTheme.bodyText2.color,
            85), //Color.fromARGB(255, 220, 220, 220),
        child: ExpansionTile(
          key: PageStorageKey<PresentableLogEntry>(logEntry),
          title: _timestampAndTitle(),
          leading: _icon(context),
          children: _details(context),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
        ));
  }

  Widget _timestamp(){
    return SelectableText(logEntry.timestamp, style: TextStyle(fontSize: 14),);
  }

  Widget _title(){
    return SelectableText(logEntry.title, style: TextStyle(fontSize: 13, fontFamily: null/*'Courier'*/),);
  }

  Widget _timestampAndTitle(){
    return Column(children: [_timestamp(), SizedBox(height: 5), _title()],
        crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> _details(BuildContext context) {
    List<Widget> details = List<Widget>();
    logEntry.detailsFields.forEach((key, value) {
      Color keyColor = darken(Theme.of(context).textTheme.bodyText2.color, 30);
      Text keyText = Text(key.toString()+': ', style: TextStyle(color: keyColor, fontSize: 13),);
      Text valueText = Text(value.toString(), style: TextStyle(fontSize: 13));
      details.add(Container(alignment:Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(10.0, 4, 10, 4),
          child: Row(children: [keyText, valueText],)));
    });
    return details;
  }

  Widget _icon(BuildContext context) {
    return Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: brighten(Theme.of(context).textTheme.bodyText2.color, 90),
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          border: new Border.all(
            color: logEntry.severity.color,
            width: 1.0,
          ),
        ),
        child: _iconText(context));
  }

  Widget _iconText(BuildContext context) {
    Severity severity = logEntry.severity;
    String severityName = severity.name.substring(0, 3).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Center(
          child: Text(severityName,
              style: TextStyle(color: severity.color, fontSize: 8.5))),
    );
  }
}
