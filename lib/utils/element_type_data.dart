//@dart=2.12

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

const DamageTypeColorsToken = 'DamageTypeColors';

extension DamageTypeColorLayers on DamageType {
  LayeredSwatch getColorLayer(BuildContext context){
    final theme = LittleLightTheme.of(context);
    switch(this){
      case DamageType.Arc:
        return theme.damageTypeLayers.damageTypeArc;
      case DamageType.Thermal:
        return theme.damageTypeLayers.damageTypeThermal;
      case DamageType.Void:
        return theme.damageTypeLayers.damageTypeVoid;
      case DamageType.Stasis:
        return theme.damageTypeLayers.damageTypeStasis;
      default:
      return theme.onSurfaceLayers;
    }
  }
}

extension EnergyTypeColorLayers on DestinyEnergyType {
  LayeredSwatch getColorLayer(BuildContext context){
    final theme = LittleLightTheme.of(context);
    switch(this){
      case DestinyEnergyType.Arc:
        return theme.damageTypeLayers.damageTypeArc;
      case DestinyEnergyType.Thermal:
        return theme.damageTypeLayers.damageTypeThermal;
      case DestinyEnergyType.Void:
        return theme.damageTypeLayers.damageTypeVoid;
      case DestinyEnergyType.Stasis:
        return theme.damageTypeLayers.damageTypeStasis;
      default:
      return theme.onSurfaceLayers;
    }
  }
}