import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';

enum ScrollAreaType {
  Characters,
  Sections,
}

extension ScrollAreaTypeLabel on ScrollAreaType {
  String label(BuildContext context) {
    switch (this) {
      case ScrollAreaType.Characters:
        return "Characters".translate(context);
      case ScrollAreaType.Sections:
        return "Sections".translate(context);
    }
  }
}

extension ObjectiveViewModeToString on ScrollAreaType {
  String get asString => this.name.toLowerCase();
}

extension StringToScrollAreaType on String {
  ScrollAreaType? get asScrollAreaType => ScrollAreaType.values.firstWhereOrNull(
        (element) => element.name.toLowerCase() == this.toLowerCase(),
      );
}
