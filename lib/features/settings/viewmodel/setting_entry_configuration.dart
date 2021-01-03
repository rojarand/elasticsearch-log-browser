import 'package:flutter/material.dart';
import 'package:elastic_log_browser/common/ui/colors.dart';
import 'package:elastic_log_browser/common/ui/dialogs/text_field_alert.dart';
import 'package:elastic_log_browser/features/settings/model/app_settings.dart';
import 'package:elastic_log_browser/features/settings/model/elasticsearch_index_validator.dart';
import 'package:elastic_log_browser/features/settings/model/http_url_validator.dart';
import 'package:elastic_log_browser/features/settings/model/mapping.dart';
import 'package:elastic_log_browser/utlis/string_utils.dart';

import 'card_data.dart';

abstract class SettingsEntryConfiguration {
  final CardData cardData;

  SettingsEntryConfiguration({this.cardData});
}

class StaticTextConfiguration extends SettingsEntryConfiguration {
  StaticTextConfiguration({CardData cardData})
      : super(cardData: cardData);
}

class TypeableConfiguration extends SettingsEntryConfiguration {
  TypeableConfiguration(
      {CardData cardData,
      this.textFieldText,
      this.hintText,
      this.textValidation,
      this.positiveButtonCallback,
      this.negativeButtonCallback})
      : super(cardData: cardData);

  final String textFieldText;
  final String hintText;
  final TextValidation textValidation;
  final TextCallback positiveButtonCallback;
  final TextCallback negativeButtonCallback;
}

class SelectableConfiguration<T> extends SettingsEntryConfiguration {
  T initialSelection;
  List<T> options;
  ValueChanged<T> positiveButtonCallback;
  ValueChanged<T> negativeButtonCallback;

  SelectableConfiguration(
      {CardData cardData,
      this.initialSelection,
      this.options,
      this.positiveButtonCallback,
      this.negativeButtonCallback})
      : super(cardData: cardData);

  void onPositiveButtonCallback(dynamic selection) {
    positiveButtonCallback(selection as T);
  }

  void onNegativeButtonCallback(dynamic selection) {
    negativeButtonCallback(selection as T);
  }
}

class SettingsEntryConfigurations {
  final List<SettingsEntryConfiguration> configurations = List();
  void add(SettingsEntryConfiguration settingsEntryConfiguration) {
    configurations.add(settingsEntryConfiguration);
  }
}

SettingsEntryConfiguration createAppVersion(AppSettings appSettings){
  CardData cardData = CardData(
      titleText: 'App version',
      subtitleText: 'v1.0.0',
      subtitleColor: null,
      detailsHtml: null);
  return StaticTextConfiguration(cardData: cardData);
}

SettingsEntryConfiguration createSeverAddressEntryConfiguration(
    {AppSettings appSettings, ValueChanged<String> serverAddressChanged}) {
  String address = appSettings.serverUrl;
  CardData cardData = CardData(
      titleText: 'Server address',
      subtitleText: address != null ? address : 'Required - expand for details',
      subtitleColor: address != null ? null : FieldNotSetWarningColor,
      detailsHtml:
      '''<p>A domain or ip address of your elasticsearch server instance. 
      It can be also an address of a proxy server.
      <br><br>SETUP: <i>Mandatory</i>
      <br><br><b>NOTE:</b>
      <br>- Keep your data secure, use the secure communication (https).
      <br>- Do not enter here a full search url, just an address.
      <p>
      ''');

  TextValidation textValidation = TextValidation(
      textValidationCallback: (String addressCandidate) {
        return HttpUrlValidator().isValid(addressCandidate);
      },
      validationErrorText: 'Enter valid url address.');
  String textFieldText = address != null ? address : "";

  return TypeableConfiguration(
      cardData: cardData,
      hintText: 'https://elasticsearch.address',
      textFieldText: textFieldText,
      textValidation: textValidation,
      positiveButtonCallback: (String serverAddress) {
        serverAddressChanged(serverAddress);
      },
      negativeButtonCallback: (String address) {});
}

SettingsEntryConfiguration createEsIndexEntryConfiguration(
    {AppSettings appSettings, ValueChanged<String> esIndexChanged}) {
  String index = appSettings.elasticsearchIndex;
  CardData cardData = CardData(
      titleText: 'Elasticsearch index',
      subtitleText: index != null ? index : 'Required - expand for details',
      subtitleColor: index != null ? DefaultColor : FieldNotSetWarningColor,
      detailsHtml:
      '''<p>Wildcards for multiple indices are supported. 
      Eg. for browsing logs with indices such as: logs-2019 and logs-2020 use logs-20* wildcard format.
      <br><br>SETUP: <i>Mandatory</i></p>
      <p>''');

  TextValidation textValidation = TextValidation(
      textValidationCallback: (String elasticsearchIndexCandidate) {
        return ElasticsearchIndexValidator()
            .isValid(elasticsearchIndexCandidate);
      },
      validationErrorText: 'Enter valid index format.');
  String textFieldText = index != null ? index : "";

  return TypeableConfiguration(
      cardData: cardData,
      hintText: 'logs-2019*',
      textFieldText: textFieldText,
      textValidation: textValidation,
      positiveButtonCallback: (String auth) {
        esIndexChanged(auth);
      },
      negativeButtonCallback: (String auth) {});
}

SettingsEntryConfiguration createTimestampConfiguration(
    {AppSettings appSettings, ValueChanged<String> timestampNameChanged}) {
  Mappings mappings = appSettings.mappings;
  if (mappings == null) {
    return null;
  }

  List<String> dateFields;
  try {
    Mapping mapping = mappings.newest();
    if (mapping == null) {
      return null;
    }
    dateFields = mapping.fieldsWithDateType;
  } catch (e) {
    dateFields = [""];
  }

  String currentFieldName = appSettings.timestampFieldName;
  Color subtitleColor = DefaultColor;
  String subtitle = '';
  if (currentFieldName == null || !dateFields.contains(currentFieldName)) {
    currentFieldName = "";
    dateFields.add(currentFieldName);
    subtitle = 'No timestamp field selected!!!';
    subtitleColor = FieldNotSetWarningColor;
  } else {
    subtitle = currentFieldName;
  }
  CardData cardData = CardData(
      titleText: 'Timestamp',
      subtitleText: subtitle,
      subtitleColor: subtitleColor,
      detailsHtml:
      '''<p>A field containing a value of a time an event occurred. 
      A field should be of type <i>date</i>.
      <br><br>SETUP: <i>Mandatory</i></p>
      ''');
  SelectableConfiguration config = SelectableConfiguration<String>(
      cardData: cardData,
      initialSelection: currentFieldName,
      options: dateFields,
      positiveButtonCallback: (String timestampFieldName) {
        timestampNameChanged(timestampFieldName);
      },
      negativeButtonCallback: (String timestampFieldName) {});
  return config;
}


SettingsEntryConfiguration createHttpAuthEntryConfiguration(
    {AppSettings appSettings, ValueChanged<String> authChanged}) {
  String auth = appSettings.httpAuthentication;
  String subtitle = '';
  if (!nullOrEmpty(auth)) {
    if (auth.length > 3) {
      subtitle = auth.substring(0, 3)+'...';
    }
  }
  CardData cardData = CardData(
      titleText: 'Authentication',
      subtitleText: subtitle,
      subtitleColor: DefaultColor,
      detailsHtml:
      '''<p>Basic access authentication.
      Used as a way to secure access to a server. Usually consists of combination of username:password. 
      <br><br>SETUP: <i>Optional</i>
      <br><br><b>NOTE:</b>
      <br>- It is required when the basic authentication is configured on a proxy server.
      <br>- Keep your password secure, use the secure communication (https).
      <p>''');

  TextValidation textValidation = TextValidation(
      textValidationCallback: (String authenticationCandidate) {
        return true;
      },
      validationErrorText: '');

  String textFieldText = appSettings.httpAuthentication != null
      ? appSettings.httpAuthentication
      : "";

  return TypeableConfiguration(
      cardData: cardData,
      hintText: 'user:password',
      textFieldText: textFieldText,
      textValidation: textValidation,
      positiveButtonCallback: (String httpAuth) {
        authChanged(httpAuth);
      },
      negativeButtonCallback: (String httpAuth) {});
}

SettingsEntryConfiguration createSeverityEntryConfiguration(
    {AppSettings appSettings, ValueChanged<String> severityNameChanged}) {
  Mappings mappings = appSettings.mappings;
  if (mappings == null) {
    return null;
  }

  List<String> textFields;
  try {
    Mapping mapping = mappings.newest();
    if (mapping == null) {
      return null;
    }
    textFields = mapping.fieldsWithTextType;
  } catch (e) {
    textFields = [""];
  }

  String currentSeverityFieldName = appSettings.severityFieldName;
  String subtitle = '';
  Color subtitleColor = DefaultColor;
  if (currentSeverityFieldName == null ||
      !textFields.contains(currentSeverityFieldName)) {
    currentSeverityFieldName = "";
    textFields.add(currentSeverityFieldName);
    subtitle = 'No severity field selected!!!';
    subtitleColor = FieldNotSetWarningColor;
  } else {
    subtitle = currentSeverityFieldName;
  }
  CardData cardData = CardData(
      titleText: 'Severity',
      subtitleText: subtitle,
      subtitleColor: subtitleColor,
      detailsHtml:
      '''<p>A field containing severity of an event. 
      The value should be one of: trace, info, debug, warning, error, fatal. 
      Selection of the field activates additional filter options. 
      <br><br>SETUP: <i>Optional</i></p>
      ''');
  SelectableConfiguration config = SelectableConfiguration<String>(
      cardData: cardData,
      initialSelection: currentSeverityFieldName,
      options: textFields,
      positiveButtonCallback: (String severityFieldName) {
        severityNameChanged(severityFieldName);
      },
      negativeButtonCallback: (String timestampFieldName) {});
  return config;
}

SettingsEntryConfiguration createLogTitleFieldConfiguration(
    {AppSettings appSettings, ValueChanged<String> titleFieldNameChanged}) {
  Mappings mappings = appSettings.mappings;
  if (mappings == null) {
    return null;
  }

  List<String> textFields;
  try {
    Mapping mapping = mappings.newest();
    if (mapping == null) {
      return null;
    }
    textFields = mapping.fieldsWithTextType;
  } catch (e) {
    textFields = [""];
  }

  String titleFieldName = appSettings.logTitleFieldName;
  String subtitle = '';
  Color subtitleColor = DefaultColor;
  if (titleFieldName == null || !textFields.contains(titleFieldName)) {
    titleFieldName = "";
    textFields.add(titleFieldName);
    subtitleColor = FieldNotSetWarningColor;
    subtitle = 'No field selected yet';
  } else {
    subtitle = titleFieldName;
  }
  CardData cardData = CardData(
      titleText: 'Log entry title',
      subtitleText: subtitle,
      subtitleColor: subtitleColor,
      detailsHtml:
      '''<p>A field which its value is displayed along with a timestamp value on a header of log entry field.<br>
      A value of that field should describe general content of a log entry.
      <br><br>SETUP: <i>Optional</i></p>
      ''');
  SelectableConfiguration config = SelectableConfiguration<String>(
      cardData: cardData,
      initialSelection: titleFieldName,
      options: textFields,
      positiveButtonCallback: (String titleFieldName) {
        titleFieldNameChanged(titleFieldName);
      },
      negativeButtonCallback: (String titleFieldFieldName) {});
  return config;
}
