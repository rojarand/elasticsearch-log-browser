import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback settingsPressed;
  final VoidCallback refreshPressed;

  AppToolbar({this.settingsPressed, this.refreshPressed})
      : super(key: const Key(""));

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text('Elastic Log Browser'), actions: <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: IconButton(
            icon: Icon(Icons.settings_rounded),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              if (settingsPressed != null) {
                settingsPressed();
              }
            }),
      ),
      Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: Icon(Icons.refresh),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              if (refreshPressed != null) {
                refreshPressed();
              }
            },
          ))
    ]);
  }
}
