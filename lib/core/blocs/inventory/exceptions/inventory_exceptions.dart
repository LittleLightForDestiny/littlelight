import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';

abstract class BaseInventoryException implements Exception {
  String getMessage(BuildContext context);
  BaseInventoryException();
}

class SubstituteNotFoundException extends BaseInventoryException {
  @override
  String getMessage(BuildContext context) {
    return context.translate(
        "Couldn't find an appropriate substitute for the current item",
        useReadContext: true);
  }
}
