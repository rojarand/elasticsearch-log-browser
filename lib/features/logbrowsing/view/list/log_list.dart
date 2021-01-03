import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:elastic_log_browser/common/loading_status_change_notifier.dart';
import 'package:elastic_log_browser/features/logbrowsing/viewmodel/logs_view_model.dart';
import 'package:provider/provider.dart';

import 'log_row.dart';

class LogList extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final LogsViewModel viewModel;

  LogList(this.viewModel) : super(key: Key("")) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        viewModel.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _listWithLoadIndicator(context);
  }

  Widget _listWithLoadIndicator(BuildContext context) {
    return Stack(
        //fit: StackFit.expand,
        children: <Widget>[
          _listenableList(context),
          _listenableProgressIndicator(context)
        ]);
  }

  Widget _listenableList(BuildContext context) {
    return ChangeNotifierProvider<LogStore>.value(
        value: viewModel.logs,
        child: Consumer<LogStore>(
            builder: (context, model, child) => _list(context)));
  }

  Widget _list(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: viewModel.numberOfLogs,
        padding: const EdgeInsets.all(4.0),
        itemBuilder: (context, i) {
          return LogRow(logEntry: viewModel.logAt(i));
        });
  }

  Widget _listenableProgressIndicator(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: ChangeNotifierProvider<LoadingStatusChangeNotifier>(
            create: (context) => viewModel.loadingStatusChangeNotifier,
            child: Consumer<LoadingStatusChangeNotifier>(
                builder: (context, model, child) => model.loading
                    ? _visibleProgressIndicator(context)
                    : _invisibleProgressIndicator(context))));
  }

  Widget _visibleProgressIndicator(BuildContext context) {
    return CircularProgressIndicator(
        backgroundColor: Theme.of(context).primaryColor);
  }

  Widget _invisibleProgressIndicator(BuildContext context) {
    return SizedBox(width: 0, height: 0);
  }
}
