import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:elastic_log_browser/common/loading_status_change_notifier.dart';
import 'package:elastic_log_browser/common/ui/dialogs/combo_box_alert.dart';
import 'package:elastic_log_browser/common/ui/dialogs/text_alert.dart';
import 'package:elastic_log_browser/common/ui/dialogs/text_field_alert.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/card_data.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/setting_entry_configuration.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/settings_management_event.dart';
import 'package:elastic_log_browser/features/settings/viewmodel/settings_view_model.dart';
import 'package:provider/provider.dart';

class SettingsRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsRouteState(SettingsViewModelImpl());
  }
}

class SettingsRouteState extends State<SettingsRoute> {
  SettingsViewModel _viewModel;

  SettingsRouteState(SettingsViewModel viewModel) {
    _viewModel = viewModel;
    _viewModel.settingsManagementEventStream.listen((event) {
      if (event is FetchSampleLogFailureEvent) {
        showErrorAlertWithDetails(
            context: context, messageWithDetails: event.messageWithDetails);
      }
    });
    _viewModel.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _buildListView(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text('App Settings'),
      leading: _backButton(context),
    );
  }

  Widget _backButton(BuildContext context) {
    return new IconButton(
      icon: new Icon(Icons.arrow_back),
      onPressed: () async {
        if(await _viewModel.canWindowBeDismissed()){
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return StreamBuilder<SettingsEntryConfigurations>(
      stream: _viewModel.settingsEntryConfig,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return _listWithLoadIndicator(context, snapshot.data);
        } else {
          return Text('Loading...');
        }
      },
    );
  }

  Widget _listWithLoadIndicator(
      BuildContext context, SettingsEntryConfigurations settingsConfigs) {
    return Stack(children: <Widget>[
      _listView(context, settingsConfigs),
      _decoratedLoadIndicator(context)
    ]);
  }

  Widget _decoratedLoadIndicator(BuildContext context) {
    return Container(
      decoration:
          new BoxDecoration(color: new Color.fromRGBO(128, 128, 128, 0.5)),
      child: _loadIndicator(),
    );
  }

  Widget _loadIndicator() {
    return ChangeNotifierProvider<LoadingStatusChangeNotifier>(
        create: (context) => _viewModel.loadingStatusChangeNotifier,
        child: Consumer<LoadingStatusChangeNotifier>(
            builder: (context, model, child) => model.loading
                ? _visibleLoadIndicator()
                : _placeholderOfLoadIndicator()));
  }

  Widget _visibleLoadIndicator() {
    return Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor));
  }

  Widget _placeholderOfLoadIndicator() {
    return SizedBox(width: 0, height: 0);
  }

  Widget _listView(BuildContext context,
      SettingsEntryConfigurations settingsEntryConfigurations) {
    List<Widget> tiles =
        settingsEntryConfigurations.configurations.map((config) {
      return _configToEntryWidget(config);
    }).toList();
    return ListView(children: tiles);
  }

  Widget _configToEntryWidget(SettingsEntryConfiguration config) {
    if (config is StaticTextConfiguration) {
      return staticTextConfigToWidget(config);
    } else if (config is TypeableConfiguration) {
      return typeableConfigToCard(config);
    } else if (config is SelectableConfiguration) {
      return selectableConfigToCard(config);
    }
    return null;
  }

  Widget staticTextConfigToWidget(StaticTextConfiguration config){
    return _titleAndSubtitle(config.cardData);
  }

  Card typeableConfigToCard(TypeableConfiguration config) {
    return _expandableCard(config.cardData, () {
      showTextFieldAlert(
          context: context,
          textFieldText: config.textFieldText,
          labelText: config.cardData.titleText,
          hintText: config.hintText,
          textValidation: config.textValidation,
          positiveButtonCallback: config.positiveButtonCallback,
          negativeButtonCallback: config.negativeButtonCallback);
    });
  }

  Card selectableConfigToCard(SelectableConfiguration config) {
    return _expandableCard(config.cardData, () {
      showComboBoxAlert(
          context: context,
          labelText: config.cardData.titleText,
          positiveButtonCallback: (dynamic selection) {
            config.onPositiveButtonCallback(selection);
          },
          negativeButtonCallback: (dynamic selection) {
            config.onNegativeButtonCallback(selection);
          },
          initialSelection: config.initialSelection,
          options: config.options);
    });
  }

  Widget _titleAndSubtitle(CardData cardData) {

    Column titleAndSubtitle = Column(children: [
      Text(cardData.titleText),
      Text(cardData.subtitleText)
    ],);
    return Container(
      // decoration: new BoxDecoration(color: Colors.white),
        child: Container(
            margin: const EdgeInsets.all(0.0),
            padding: const EdgeInsets.fromLTRB(5, 20, 5, 10),
            child: titleAndSubtitle));
  }

  Card _expandableCard(CardData cardData, VoidCallback onPressed) {
    Widget leadingWidget;
    if (onPressed!=null) {
      leadingWidget = IconButton(icon: Icon(Icons.edit), onPressed: onPressed);
    }
    List<Widget> children = [];
    if(cardData.detailsHtml != null){
      children = [Html(data: cardData.detailsHtml, padding: _htmlPadding())];
    }
    return Card(
          child: ExpansionTile(
            key: PageStorageKey<String>(cardData.titleText),
            leading: leadingWidget,
            title: Text(cardData.titleText),
            subtitle: Text(cardData.subtitleText, style: TextStyle(color: cardData.subtitleColor)),
            children: children,
          ));
  }

  EdgeInsets _htmlPadding() {
    return EdgeInsets.fromLTRB(30, 0, 30, 0);
  }
}
