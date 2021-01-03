import 'package:flutter/material.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

abstract class Alertable extends StatefulWidget {
  final String title;
  final String positiveButtonText;
  final String negativeButtonText;

  const Alertable(
      {this.title, this.positiveButtonText, this.negativeButtonText})
      : super(key: const Key(""));
}

abstract class AlertableState<T extends Alertable> extends State<T> {
  void onPositiveButtonTapped(BuildContext context);

  void onNegativeButtonTapped(BuildContext context);

  bool get showNegativeButton => true;

  bool get showPositiveButton => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
          title: new Text(widget.title),
          content: content(context),
          actions: _actionButtons(context)),
    );
  }

  Widget content(BuildContext context);

  List<Widget> _actionButtons(BuildContext context) {
    List<Widget> buttons = List<Widget>();
    if (showNegativeButton) {
      buttons.add(FlatButton(
          child: Text(
              _buttonText(candidate: widget.negativeButtonText, alt: 'Cancel')),
          onPressed: () {
            onNegativeButtonTapped(context);
          }));
    }
    if (showPositiveButton) {
      buttons.add(FlatButton(
          child: Text(
              _buttonText(candidate: widget.positiveButtonText, alt: 'OK')),
          onPressed: () {
            onPositiveButtonTapped(context);
          }));
    }
    return buttons;
  }

  String _buttonText({String candidate, @required String alt}) {
    return nullOrEmpty(candidate) ? alt : candidate;
  }
}
