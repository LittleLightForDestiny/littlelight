import 'package:bungie_api/src/enums/destiny_breaker_type.dart';
import 'package:flutter/src/widgets/icon_data.dart';
import 'package:little_light/utils/destiny_data.dart';

extension DestinyBreakerTypeData on DestinyBreakerType {
  IconData? get icon {
    return DestinyData.getBreakerTypeIcon(this);
  }
}