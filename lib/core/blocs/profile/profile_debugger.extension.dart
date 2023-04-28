import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/exceptions.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/bungie_api.exception.dart';

import '../../../models/item_info/destiny_item_info.dart';

extension ProfileDebuggerExtension on ProfileBloc {
  Future<void> mockTransfer(DestinyItemInfo itemInfo, int stackSize, bool transferToVault, String characterId) async {
    await Future.delayed(Duration(milliseconds: 2000));
    if (transferToVault) return;
    final hasSpace = await hasSpaceFor(characterId, itemInfo);
    if (!hasSpace) {
      throw BungieApiException.fromJson({"ErrorCode": PlatformErrorCodes.DestinyNoRoomInDestination.value});
    }
  }

  Future<bool> hasSpaceFor(String? characterId, DestinyItemInfo itemInfo) async {
    if (characterId == null) return true;
    final hash = itemInfo.itemHash;
    if (hash == null) return false;
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    final bucketHash = def?.inventory?.bucketTypeHash;
    if (bucketHash == null) return false;
    final bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(bucketHash);
    final bucketItemCount = allInstancedItems
        .where((element) => element.bucketHash == bucketHash && element.characterId == characterId)
        .length;
    final availableCount = bucketDef?.itemCount ?? 0;
    return availableCount > bucketItemCount;
  }
}
