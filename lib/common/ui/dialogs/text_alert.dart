import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/friendly_message_formatter.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

import 'alertable.dart';

Future<void> showErrorAlertWithDetails(
    {@required BuildContext context,
    MessageWithDetails messageWithDetails,
    VoidCallback buttonCallback}) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return TextAlert(
            title: 'Error',
            message: messageWithDetails.message,
            details: messageWithDetails.details,
            positiveButtonCallback: buttonCallback);
      });
}

Future<void> showErrorAlert(
    {@required BuildContext context,
    String message,
    String details,
    VoidCallback buttonCallback}) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return TextAlert(
            title: 'Error',
            message: message,
            details: details,
            positiveButtonCallback: buttonCallback);
      });
}

class TextAlert extends Alertable {
  final String message;
  final String details;
  final VoidCallback positiveButtonCallback;
  final VoidCallback negativeButtonCallback;

  TextAlert(
      {String title,
      this.message,
      this.details,
      String positiveButtonText,
      this.positiveButtonCallback,
      String negativeButtonText,
      this.negativeButtonCallback})
      : super(
            title: title,
            positiveButtonText: positiveButtonText,
            negativeButtonText: negativeButtonText);

  @override
  TextAlertState createState() {
    return TextAlertState();
  }
}

class TextAlertState extends AlertableState<TextAlert> {
  @override
  Widget content(BuildContext context) {
    return SingleChildScrollView(
      child: ListBody(
        children: _messageTextAndMaybeDetails(context),
      ),
    );
  }

  List<Widget> _messageTextAndMaybeDetails(BuildContext context) {
    List<Widget> widgets = List();
    widgets.add(Text(widget.message));
    if (!nullOrEmpty(widget.details)) {
      widgets.add(ExpansionTile(
        key: PageStorageKey<String>(""),
        title: Text('Details'),
        children: [Text(widget.details)],
      ));
    }
    return widgets;
  }

  bool get showNegativeButton => false;

  @override
  void onNegativeButtonTapped(BuildContext context) {}

  @override
  void onPositiveButtonTapped(BuildContext context) {
    Navigator.pop(context);
    widget.positiveButtonCallback();
  }
}
