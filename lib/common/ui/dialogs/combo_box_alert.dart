import 'package:flutter/material.dart';

import 'alertable.dart';

void showComboBoxAlert<T>(
    {@required BuildContext context,
    @required String labelText,
    String positiveButtonText,
    ValueChanged<T> positiveButtonCallback,
    String negativeButtonText,
    ValueChanged<T> negativeButtonCallback,
    T initialSelection,
    List<T> options}) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return ComboBoxAlertDialog<T>(
            title: labelText,
            positiveButtonText: positiveButtonText,
            positiveButtonCallback: positiveButtonCallback,
            negativeButtonText: negativeButtonText,
            negativeButtonCallback: negativeButtonCallback,
            initialSelection: initialSelection,
            options: options);
      });
}

class ComboBoxAlertDialog<T> extends Alertable {
  final ValueChanged<T> positiveButtonCallback;
  final ValueChanged<T> negativeButtonCallback;
  final T initialSelection;
  final List<T> options;

  ComboBoxAlertDialog(
      {String title,
      String positiveButtonText,
      this.positiveButtonCallback,
      String negativeButtonText,
      this.negativeButtonCallback,
      this.initialSelection,
      this.options})
      : super(
            title: title,
            positiveButtonText: positiveButtonText,
            negativeButtonText: negativeButtonText);

  @override
  ComboBoxAlertDialogState createState() {
    return ComboBoxAlertDialogState<T>(currentSelection: initialSelection);
  }

  List<DropdownMenuItem<T>> createMenuItems() {
    return options
        .map((t) => DropdownMenuItem(value: t, child: new Text(t.toString())))
        .toList();
  }
}

class ComboBoxAlertDialogState<T>
    extends AlertableState<ComboBoxAlertDialog<T>> {
  T _currentSelection;

  ComboBoxAlertDialogState({T currentSelection, ValueChanged<T> valueChanged}) {
    _currentSelection = currentSelection;
  }

  @override
  Widget content(BuildContext context) {
    return DropdownButton(
      value: _currentSelection,
      items: widget.createMenuItems(),
      onChanged: (T changed) {
        setState(() {
          _currentSelection = changed;
        });
      },
    );
  }

  @override
  void onNegativeButtonTapped(BuildContext context) {
    widget.negativeButtonCallback(_currentSelection);
    Navigator.pop(context);
  }

  @override
  void onPositiveButtonTapped(BuildContext context) {
    widget.positiveButtonCallback(_currentSelection);
    Navigator.pop(context);
  }
}
