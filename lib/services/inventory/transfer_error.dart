import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/enums/platform_error_codes.dart';

import 'enums/item_destination.dart';
import 'enums/transfer_error_type.dart';

class TransferError {
  final TransferErrorType code;
  final DestinyItemComponent? item;
  final ItemDestination? destination;
  final String? characterId;
  final PlatformErrorCodes? platformError;

  TransferError(this.code,
      {this.item, this.destination, this.characterId, this.platformError});
}
