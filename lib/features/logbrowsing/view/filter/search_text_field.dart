import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/colors.dart';

typedef TextCallback = void Function(String text);

class SearchTextFieldWidget extends StatefulWidget {
  final TextCallback textCallback;

  SearchTextFieldWidget(this.textCallback);

  @override
  State<StatefulWidget> createState() {
    return SearchTextField(textCallback);
  }
}

class SearchTextField extends State<SearchTextFieldWidget> {
  final TextEditingController _controller = TextEditingController();
  final TextCallback _textCallback;
  bool _isEmpty = true;

  SearchTextField(this._textCallback);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _searchTextFieldWithPadding(context);
  }

  Widget _searchTextFieldWithPadding(BuildContext context) {
    return Container(
        // decoration: new BoxDecoration(color: Colors.white),
        child: Container(
            margin: const EdgeInsets.all(0.0),
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: _decoration(context), //       <--- BoxDecoration here
            child: _searchTextField()));
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
      color: brighten(Theme.of(context).primaryColor, 80),
      border: Border.all(
          width: 1.5,
          color: brighten(Theme.of(context).textTheme.subtitle1.color, 80)),
      borderRadius: BorderRadius.all(
          Radius.circular(25.0) //         <--- border radius here
          ),
    );
  }

  Widget _searchTextField() {
    return Row(
      children: [_searchIcon(), _textField(), _clearTextButton()],
    );
  }

  Widget _searchIcon() {
    return Icon(Icons.search);
  }

  Widget _textField() {
    return Expanded(
        child: TextField(
      controller: _controller,
      onChanged: (String text) {
        onTextChange(text);
      },
      decoration: new InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(10, 0, 20, 0),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Search...',
          hintStyle: TextStyle(
              color:
                  brighten(Theme.of(context).textTheme.subtitle1.color, 40))),
    ));
  }

  Widget _clearTextButton() {
    final double sizeCandidate = Theme.of(context).iconTheme.size;
    final double size = sizeCandidate != null ? sizeCandidate : 24;
    if (_isEmpty) {
      return SizedBox(width: size, height: size);
    } else {
      return Container(
        padding: const EdgeInsets.all(0.0),
        width: size, // you can adjust the width as you need
        height: size, // you can adjust the width as you need
        child: IconButton(
            iconSize: size - 4,
            icon: Icon(Icons.close),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            onPressed: () {
              _controller.clear();
              onTextChange(_controller.text);
            }),
      );
    }
  }

  void onTextChange(String text) {
    if (text.isEmpty != _isEmpty) {
      setState(() {
        _isEmpty = text.isEmpty;
      });
    }
    if (_textCallback != null) {
      _textCallback(text);
    }
  }
}
