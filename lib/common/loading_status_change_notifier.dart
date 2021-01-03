import 'package:flutter/cupertino.dart';

class LoadingStatusChangeNotifier extends ChangeNotifier {
  bool _loading = false;

  bool get loading => _loading;

  void onLoadBegin() {
    _loading = true;
    notifyListeners();
  }

  void onLoadEnd() {
    _loading = false;
    notifyListeners();
  }
}
