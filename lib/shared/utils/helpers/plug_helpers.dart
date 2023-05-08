import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

const _blockedForApplyingPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _trackerPlugCategories = [r'^.*?\.weapons\.masterworks\.trackers$'];
const _ornamentPlugCategories = [r'^.*?skins.*?$'];

bool canApplyPlug(
  BuildContext context,
  DestinyItemInfo item,
  int? socketIndex,
  int? plugHash,
  DestinyInventoryItemDefinition? plugDef,
  DestinyMaterialRequirementSetDefinition? materialCost,
) {
  if (socketIndex == null || plugHash == null) return false;
  final allowActions = plugDef?.allowActions ?? false;
  if (allowActions == false) return false;
  final isEquipped = item.sockets?[socketIndex].plugHash == plugHash;
  if (isEquipped) return false;
  final hasMaterials = materialCost?.materials?.isNotEmpty ?? false;
  if (hasMaterials) return false;
  if (isPlugBlockedForApplying(context, plugDef)) return false;
  return true;
}

bool isPlugBlockedForApplying(BuildContext context, DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  return _blockedForApplyingPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}

bool isTrackerPlug(BuildContext context, DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  return _trackerPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}

bool shouldPlugOverrideStyleItemHash(DestinyInventoryItemDefinition? def) {
  final categoryId = def?.plug?.plugCategoryIdentifier;
  if (categoryId == null) return false;
  if (def?.plug?.isDummyPlug ?? false) return false;
  return _ornamentPlugCategories.any((r) {
    return RegExp(r).hasMatch(categoryId);
  });
}
