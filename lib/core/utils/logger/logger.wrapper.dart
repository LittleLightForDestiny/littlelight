import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

final logger = LoggerBloc();

class LoggerBloc {
  Logger _logger = Logger();
  void debug(dynamic message) => _logger.d(message);
  void error(dynamic message) => _logger.d(message);
  void info(dynamic message) => _logger.d(message);
}
