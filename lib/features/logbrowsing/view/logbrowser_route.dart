import 'dart:async';

import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/colors.dart';
import 'package:elastic_log_browser/common/ui/dialogs/text_alert.dart';
import 'package:elastic_log_browser/features/logbrowsing/viewmodel/log_browsing_event.dart';
import 'package:elastic_log_browser/features/settings/view/settings_route.dart';
import 'package:provider/provider.dart';

import '../viewmodel/logs_view_model.dart';
import 'app_toolbar.dart';
import 'filter/filter_widget.dart';
import 'list/log_list.dart';

class LogBrowserView extends StatefulWidget {
  @override
  LogBrowserState createState() {
    return LogBrowserState();
  }
}

class LogBrowserState extends State<LogBrowserView> {
  static const double bottomPaddingOfSpaceBarTitle = 15;
  static const double heightOfLogsCounterBackground =
      bottomPaddingOfSpaceBarTitle * 2 + 20;
  static const double heightOfFilterWidget =
      heightOfLogsCounterBackground + 160;

  final LogsViewModel _viewModel = LogsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.logBrowsingEventNotifier.stream.listen((event) {
      if (event is FetchLogsFailureEvent) {
        showErrorAlertWithDetails(
            context: context, messageWithDetails: event.messageWithDetails);
      } else if (event is SettingsNeededEvent) {
        _navigateToSettings();
      }
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    AppToolbar appToolbar = AppToolbar(
        settingsPressed: _navigateToSettings, refreshPressed: _reload);
    return Scaffold(
        appBar: appToolbar, body: Scaffold(body: _body(context)));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _load() {
    _viewModel.load();
  }

  void _removeAllLogs() {
    _viewModel.removeAllLogs();
  }

  void _reload() {
    setState(() {
      _removeAllLogs();
      _load();
    });
  }

  Widget _body(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[_appBarWithFilter(context)];
        },
        body: LogList(_viewModel));
  }

  Widget _appBarWithFilter(BuildContext context) {
    return SliverAppBar(
        expandedHeight: heightOfFilterWidget,
        floating: false,
        pinned: true,
        flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return _filterWithLogsCounter();
        }));
  }

  Widget _filterWithLogsCounter() {
    return FlexibleSpaceBar(
        centerTitle: true,
        titlePadding:
            EdgeInsets.fromLTRB(0, 0, 0, bottomPaddingOfSpaceBarTitle),
        title: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: 0.7,
            child: _logsCounter()),
        background: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _asyncExpandedFilterWidget(),
              _logsCounterBackground()
            ]));
  }

  Widget _asyncExpandedFilterWidget() {
    Widget widget = StreamBuilder<FilterWidgetParameters>(
      stream: _viewModel.filterWidgetParametersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return _expandedFilterWidget(snapshot.data);
        } else {
          return Text('Loading ...');
        }
      },
    );
    return widget;
  }

  Widget _expandedFilterWidget(FilterWidgetParameters filterWidgetParameters) {
    return Expanded(
        child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: FilterWidget(filterWidgetParameters, _viewModel.filterParamsChanged)
        ));
  }

  Widget _logsCounterBackground() {
    return Stack(children: <Widget>[
      Container(
          height: heightOfLogsCounterBackground,
          color: Theme.of(context)
              .primaryColor) //darken(Theme.of(context).primaryColor, 2))
    ]);
  }

  Widget _logsCounter() {
    return ChangeNotifierProvider<LogStore>.value(
        value: _viewModel.logs,
        child: Consumer<LogStore>(
            builder: (context, model, child) => Text(
                "${_viewModel.numberOfLogs} logs loaded",
                style: TextStyle(
                    fontSize: 11.0,
                    color: brighten(
                        Theme.of(context).textTheme.bodyText2.color, 20)))));
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsRoute()),
    );
    _viewModel.onSettingsMayHaveChanged();
  }
}
