import '../../../common/friendly_message_formatter.dart';

class SettingsManagementEvent {}

class FetchSampleLogFailureEvent implements SettingsManagementEvent {
  dynamic _cause;

  FetchSampleLogFailureEvent(this._cause);

  MessageWithDetails get messageWithDetails =>
      FriendlyMessageFormatter.formatFromException(_cause);
}

class FetchSampleLogSuccessEvent implements SettingsManagementEvent {}
