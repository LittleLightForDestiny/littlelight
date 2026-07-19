import 'dart:io';

extension FixFilePathSeparators on String {
  String fixFilePathSeparators() {
    final correctSeparator = Platform.pathSeparator;
    return replaceAll(RegExp(r'/|\\'), correctSeparator);
  }
}
