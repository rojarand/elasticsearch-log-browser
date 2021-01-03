import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/dialogs/alertable.dart';

typedef TextCallback = void Function(String text);
typedef TextValidationCallback = bool Function(String value);

class TextValidation {
  final TextValidationCallback textValidationCallback;
  final String validationErrorText;

  TextValidation(
      {@required this.textValidationCallback, this.validationErrorText});
}

void showTextFieldAlert(
    {@required BuildContext context,
    @required String labelText,
    String textFieldText,
    String hintText,
    String positiveButtonText,
    TextCallback positiveButtonCallback,
    String negativeButtonText,
    TextCallback negativeButtonCallback,
    TextValidation textValidation}) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return TextFieldAlertDialog(
            title: labelText,
            textFieldText: textFieldText,
            hintText: hintText,
            textValidation: textValidation,
            positiveButtonText: positiveButtonText,
            positiveButtonCallback: positiveButtonCallback,
            negativeButtonText: negativeButtonText,
            negativeButtonCallback: negativeButtonCallback);
      });
}

class TextFieldAlertDialog extends Alertable {
  final String textFieldText;
  final String hintText;
  final TextCallback positiveButtonCallback;
  final TextCallback negativeButtonCallback;
  final TextValidation textValidation;

  const TextFieldAlertDialog(
      {String title,
      this.textFieldText,
      this.hintText,
      String positiveButtonText,
      this.positiveButtonCallback,
      String negativeButtonText,
      this.negativeButtonCallback,
      this.textValidation})
      : super(
            title: title,
            positiveButtonText: positiveButtonText,
            negativeButtonText: negativeButtonText);

  @override
  TextFieldAlertDialogState createState() {
    return TextFieldAlertDialogState();
  }
}

class TextFieldAlertDialogState extends AlertableState<TextFieldAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool _validateSuccess = false;
  String _savedText;

  @override
  Widget content(BuildContext context) {
    _textController.text =
        _savedText != null ? _savedText : widget.textFieldText;
    return Form(
        key: _formKey,
        autovalidate: _validateSuccess,
        child: TextFormField(
          validator: (value) {
            if (!widget.textValidation.textValidationCallback(value)) {
              return widget.textValidation.validationErrorText;
            }
            return null;
          },
          onSaved: (String val) {},
          controller: _textController,
          autofocus: true,
          decoration: new InputDecoration(
              labelText: '',
              hintText: widget.hintText != null ? widget.hintText : ''),
        )
        //),
        );
  }

  @override
  void onNegativeButtonTapped(BuildContext context) {
    Navigator.pop(context);
    if (widget.negativeButtonCallback != null) {
      widget.negativeButtonCallback(_textController.text);
    }
  }

  @override
  void onPositiveButtonTapped(BuildContext context) {
    if (_formKey.currentState.validate()) {
      Navigator.pop(context);
      if (widget.positiveButtonCallback != null) {
        widget.positiveButtonCallback(_textController.text);
      }
    } else {
      setState(() {
        _savedText = _textController.text;
        _validateSuccess = false;
      });
    }
  }
}
