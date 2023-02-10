import 'package:bungie_api/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';

extension TransferErrorMessages on BuildContext {
  String getTransferErrorMessage(BungieApiException? exception) {
    switch (exception?.errorCode) {
      case PlatformErrorCodes.DestinyItemNotFound:
        return "The selected item was not found on the expected location. Please update the inventory and try again."
            .translate(this, useReadContext: true);
      case PlatformErrorCodes.DestinyNoRoomInDestination:
        return "There's no room in the selected destination. Please clear some inventory space and try again."
            .translate(this, useReadContext: true);
      case PlatformErrorCodes.DestinyItemUniqueEquipRestricted:
        return "Can't equip 2 exotics at the same time.".translate(this, useReadContext: true);
      default:
        if (exception != null) {
          getInjectedAnalyticsService().registerNonFatal(
              Exception("Got an unexpected error code during a transfer ${exception.errorCode}"), null);
        }
        return "The transfer couldn't be completed because of an unexpected error"
            .translate(this, useReadContext: true);
    }
  }
}
