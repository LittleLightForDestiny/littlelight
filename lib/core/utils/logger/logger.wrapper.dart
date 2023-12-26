import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = LoggerBloc();

class LogEntry {
  Level level;
  dynamic message;
  dynamic error;
  StackTrace? stackTrace;
  LogEntry(this.level, this.message, this.error, this.stackTrace);
}

// const _maxMessages = 50;

class LoggerBloc extends ChangeNotifier {
  List<LogEntry> _messages = [];
  Logger _logger;

  factory LoggerBloc() {
    final logger = Logger();
    return LoggerBloc._(logger);
  }

  LoggerBloc._(this._logger) : super();

  void debug(dynamic message) {
    _logger.d(message);
  }

  void error(dynamic message, {dynamic error, StackTrace? stack, bool keepExternalStackTraces = false}) {
    final relevantStackTraceMessages = stack?.toString().split('\n').where((s) => s.contains('package:little_light'));
    if (relevantStackTraceMessages != null && !keepExternalStackTraces) {
      stack = StackTrace.fromString(relevantStackTraceMessages.join('\n'));
    }
    _logger.e(message, error: error, stackTrace: stack);
  }

  void info(dynamic message) {
    _logger.i(message);
  }

  List<LogEntry> get messages {
    return _messages;
  }
}
