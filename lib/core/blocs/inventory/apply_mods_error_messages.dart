import 'package:bungie_api/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';

extension ApplyModsErrorMessages on BuildContext {
  String getApplyModsErrorMessage(BungieApiException? exception) {
    switch (exception?.errorCode) {
      case PlatformErrorCodes.DestinySocketActionNotAllowed:
        return "The selected socket can't be applied throught the API or third party apps like Little Light."
            .translate(this, useReadContext: true);
      //TODO: evaluate other possible error messages while applying sockets
      // case PlatformErrorCodes.DestinyNoRoomInDestination:
      //   return "There's no room in the selected destination. Please clear some inventory space and try again."
      //       .translate(this, useReadContext: true);
      // case PlatformErrorCodes.DestinyItemUniqueEquipRestricted:
      //   return "Can't equip 2 exotics at the same time.".translate(this, useReadContext: true);
      default:
        if (exception != null) {
          getInjectedAnalyticsService().registerNonFatal(
              Exception("Got an unexpected error code while applying plugs ${exception.errorCode}"), null);
        }
        return "The operation couldn't be completed because of an unexpected error"
            .translate(this, useReadContext: true);
    }
  }
}
