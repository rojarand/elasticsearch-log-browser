import 'dart:io';

import 'package:elastic_log_browser/features/logbrowsing/model/es_doc_request.dart';

class MessageWithDetails {
  final String message;
  final String details;

  const MessageWithDetails({this.message, this.details});
}

class FriendlyMessageFormatter {
  static MessageWithDetails formatFromException(dynamic cause) {
    if (cause is NoSuchMethodError) {
      return MessageWithDetails(
          message: 'Internal app error.',
          details:
              'It may mean that the app deals with data with a unsupported format.');
    } else if (cause is FormatException) {
      return MessageWithDetails(
          message: 'Could not parse the response.', details: cause.message);
    } else if (cause is SocketException) {
      return _formatFromSocketException(cause);
    } else if (cause is NotHttpStatus200ResponseException) {
      return _formatFromNotHttpStatus200Exception(cause);
    }

    try
    {
      var message = cause.message;
      return MessageWithDetails(message: 'Error occurred', details: message);
    }
    catch (RuntimeBinderException) {
    }

    try
    {
      var message = cause.toString();
      return MessageWithDetails(message: 'Error occurred', details: message);
    }
    catch (Exception) {
      return MessageWithDetails(message: 'Error occurred', details: '');
    }
  }

  static MessageWithDetails _formatFromSocketException(
      SocketException exception) {
    if (exception.osError.errorCode == 8) {
      return MessageWithDetails(
          message: 'Could not find the server address.',
          details: 'Check the internet connection on this device.');
    } else if (exception.osError.errorCode == 61) {
      return MessageWithDetails(
          message: 'Connection refused.',
          details: 'Check the server address or its availability.');
    } else {
      return MessageWithDetails(
          message: 'Network connectivity problem.',
          details: exception.osError.message);
    }
  }

  static MessageWithDetails _formatFromNotHttpStatus200Exception(
      NotHttpStatus200ResponseException exception) {
    if (exception.response.statusCode == 401) {
      return MessageWithDetails(
          message: 'Authentication failed.',
          details:
              'It may mean that you set up an authentication on the server side.' +
                  ' Check the authentication section in the app settings.');
    }
    else if (exception.response.statusCode == 404) {
      return MessageWithDetails(
          message: 'Resource not found.',
          details:
          'It may mean that you set up the index incorrectly or data not exists.');
    }
    else {
      return MessageWithDetails(
          message: 'Unexpected response received.',
          details: exception.response.body);
    }
  }
}
