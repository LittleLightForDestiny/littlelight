import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

extension TierTypeColorLayers on TierType {
  LayeredSwatch getColorLayer(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    switch (this) {
      case TierType.Basic:
        return theme.tierLayers.basic;
      case TierType.Common:
        return theme.tierLayers.common;
      case TierType.Rare:
        return theme.tierLayers.rare;
      case TierType.Superior:
        return theme.tierLayers.superior;
      case TierType.Exotic:
        return theme.tierLayers.exotic;
      default:
        return theme.tierLayers.basic;
    }
  }

  Color getTextColor(BuildContext context) {
    final theme = LittleLightTheme.of(context);
    switch (this) {
      case TierType.Basic:
      case TierType.Unknown:
      case TierType.Currency:
      case TierType.ProtectedInvalidEnumValue:
        return theme.surfaceLayers.layer3;

      default:
        return theme.onSurfaceLayers;
    }
  }

  Color getColor(BuildContext context) {
    return getColorLayer(context).layer0;
  }
}
