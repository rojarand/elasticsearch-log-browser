import 'package:elastic_log_browser/common/friendly_message_formatter.dart';

class LogBrowsingEvent {}

class FetchLogsFailureEvent implements LogBrowsingEvent {
  dynamic _cause;

  FetchLogsFailureEvent(this._cause);

  MessageWithDetails get messageWithDetails =>
      FriendlyMessageFormatter.formatFromException(_cause);
}

class FetchLogsSuccessEvent implements LogBrowsingEvent {
  FetchLogsSuccessEvent();
}

class SettingsNeededEvent implements LogBrowsingEvent {}
