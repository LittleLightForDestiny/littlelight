import 'package:logger/logger.dart';

final logger = LoggerBloc();

class LoggerBloc {
  Logger _logger = Logger();
  void debug(dynamic message) => _logger.d(message);
  void error(dynamic message, {dynamic error, StackTrace? stack, bool keepExternalStackTraces = false}) {
    final relevantStackTraceMessages = stack?.toString().split('\n').where((s) => s.contains('package:little_light'));
    if (relevantStackTraceMessages != null && !keepExternalStackTraces) {
      stack = StackTrace.fromString(relevantStackTraceMessages.join('\n'));
    }
    _logger.e(message, error, stack);
  }

  void info(dynamic message) => _logger.i(message);
}
