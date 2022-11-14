import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';

extension DestinyAmmunitionTypeData on DestinyAmmunitionType {
  IconData? get icon {
    return DestinyData.getAmmoTypeIcon(this);
  }

  Color? get color {
    return DestinyData.getAmmoTypeColor(this);
  }
}
