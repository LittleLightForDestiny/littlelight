import 'package:bungie_api/models/destiny_place_definition.dart';
import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_activity_type_definition.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_gender_definition.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_unlock_definition.dart';
import 'package:bungie_api/models/destiny_material_requirement_set_definition.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:bungie_api/models/destiny_faction_definition.dart';
import 'package:bungie_api/models/destiny_vendor_group_definition.dart';
import 'package:bungie_api/models/destiny_reward_source_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:bungie_api/models/destiny_damage_type_definition.dart';
import 'package:bungie_api/models/destiny_activity_mode_definition.dart';
import 'package:bungie_api/models/destiny_activity_graph_definition.dart';
import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_tier_type_definition.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:bungie_api/models/destiny_destination_definition.dart';
import 'package:bungie_api/models/destiny_equipment_slot_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_location_definition.dart';
import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_progression_level_requirement_definition.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_socket_type_definition.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';
import 'package:bungie_api/models/destiny_milestone_definition.dart';
import 'package:bungie_api/models/destiny_activity_modifier_definition.dart';
import 'package:bungie_api/models/destiny_report_reason_category_definition.dart';
import 'package:bungie_api/models/destiny_plug_set_definition.dart';
import 'package:bungie_api/models/destiny_checklist_definition.dart';
import 'package:bungie_api/models/destiny_historical_stats_definition.dart';

class DefinitionTableNames {
	static String destinyEnemyRaceDefinition = "DestinyEnemyRaceDefinition";
  static String destinyPlaceDefinition = "DestinyPlaceDefinition";
  static String destinyActivityDefinition = "DestinyActivityDefinition";
  static String destinyActivityTypeDefinition = "DestinyActivityTypeDefinition";
  static String destinyClassDefinition = "DestinyClassDefinition";
  static String destinyGenderDefinition = "DestinyGenderDefinition";
  static String destinyInventoryBucketDefinition = "DestinyInventoryBucketDefinition";
  static String destinyRaceDefinition = "DestinyRaceDefinition";
  static String destinyTalentGridDefinition = "DestinyTalentGridDefinition";
  static String destinyUnlockDefinition = "DestinyUnlockDefinition";
  static String destinyMaterialRequirementSetDefinition = "DestinyMaterialRequirementSetDefinition";
  static String destinySandboxPerkDefinition = "DestinySandboxPerkDefinition";
  static String destinyStatGroupDefinition = "DestinyStatGroupDefinition";
  static String destinyFactionDefinition = "DestinyFactionDefinition";
  static String destinyVendorGroupDefinition = "DestinyVendorGroupDefinition";
  static String destinyRewardSourceDefinition = "DestinyRewardSourceDefinition";
  static String destinyItemCategoryDefinition = "DestinyItemCategoryDefinition";
  static String destinyDamageTypeDefinition = "DestinyDamageTypeDefinition";
  static String destinyActivityModeDefinition = "DestinyActivityModeDefinition";
  static String destinyMedalTierDefinition = "DestinyMedalTierDefinition";
  static String destinyAchievementDefinition = "DestinyAchievementDefinition";
  static String destinyActivityGraphDefinition = "DestinyActivityGraphDefinition";
  static String destinyCollectibleDefinition = "DestinyCollectibleDefinition";
  static String destinyStatDefinition = "DestinyStatDefinition";
  static String destinyItemTierTypeDefinition = "DestinyItemTierTypeDefinition";
  static String destinyPresentationNodeDefinition = "DestinyPresentationNodeDefinition";
  static String destinyRecordDefinition = "DestinyRecordDefinition";
  static String destinyBondDefinition = "DestinyBondDefinition";
  static String destinyDestinationDefinition = "DestinyDestinationDefinition";
  static String destinyEquipmentSlotDefinition = "DestinyEquipmentSlotDefinition";
  static String destinyInventoryItemDefinition = "DestinyInventoryItemDefinition";
  static String destinyLocationDefinition = "DestinyLocationDefinition";
  static String destinyLoreDefinition = "DestinyLoreDefinition";
  static String destinyObjectiveDefinition = "DestinyObjectiveDefinition";
  static String destinyProgressionDefinition = "DestinyProgressionDefinition";
  static String destinyProgressionLevelRequirementDefinition = "DestinyProgressionLevelRequirementDefinition";
  static String destinySackRewardItemListDefinition = "DestinySackRewardItemListDefinition";
  static String destinySandboxPatternDefinition = "DestinySandboxPatternDefinition";
  static String destinySocketCategoryDefinition = "DestinySocketCategoryDefinition";
  static String destinySocketTypeDefinition = "DestinySocketTypeDefinition";
  static String destinyVendorDefinition = "DestinyVendorDefinition";
  static String destinyMilestoneDefinition = "DestinyMilestoneDefinition";
  static String destinyActivityModifierDefinition = "DestinyActivityModifierDefinition";
  static String destinyReportReasonCategoryDefinition = "DestinyReportReasonCategoryDefinition";
  static String destinyPlugSetDefinition = "DestinyPlugSetDefinition";
  static String destinyChecklistDefinition = "DestinyChecklistDefinition";
  static String destinyHistoricalStatsDefinition = "DestinyHistoricalStatsDefinition";

  static Map<String, Function> identities = {
    "DestinyEnemyRaceDefinition" : (def)=>def,
    "DestinyPlaceDefinition" : DestinyPlaceDefinition.fromMap,
    "DestinyActivityDefinition" : DestinyActivityDefinition.fromMap,
    "DestinyActivityTypeDefinition" : DestinyActivityTypeDefinition.fromMap,
    "DestinyClassDefinition" : DestinyClassDefinition.fromMap,
    "DestinyGenderDefinition" : DestinyGenderDefinition.fromMap,
    "DestinyInventoryBucketDefinition" : DestinyInventoryBucketDefinition.fromMap,
    "DestinyRaceDefinition" : DestinyRaceDefinition.fromMap,
    "DestinyTalentGridDefinition" : DestinyTalentGridDefinition.fromMap,
    "DestinyUnlockDefinition" : DestinyUnlockDefinition.fromMap,
    "DestinyMaterialRequirementSetDefinition" : DestinyMaterialRequirementSetDefinition.fromMap,
    "DestinySandboxPerkDefinition" : DestinySandboxPerkDefinition.fromMap,
    "DestinyStatGroupDefinition" : DestinyStatGroupDefinition.fromMap,
    "DestinyFactionDefinition" : DestinyFactionDefinition.fromMap,
    "DestinyVendorGroupDefinition" : DestinyVendorGroupDefinition.fromMap,
    "DestinyRewardSourceDefinition" : DestinyRewardSourceDefinition.fromMap,
    "DestinyItemCategoryDefinition" : DestinyItemCategoryDefinition.fromMap,
    "DestinyDamageTypeDefinition" : DestinyDamageTypeDefinition.fromMap,
    "DestinyActivityModeDefinition" : DestinyActivityModeDefinition.fromMap,
    "DestinyMedalTierDefinition" : (def)=>def,
    "DestinyAchievementDefinition" : (def)=>def,
    "DestinyActivityGraphDefinition" : DestinyActivityGraphDefinition.fromMap,
    "DestinyCollectibleDefinition" : DestinyCollectibleDefinition.fromMap,
    "DestinyStatDefinition" : DestinyStatDefinition.fromMap,
    "DestinyItemTierTypeDefinition" : DestinyItemTierTypeDefinition.fromMap,
    "DestinyPresentationNodeDefinition" : DestinyPresentationNodeDefinition.fromMap,
    "DestinyRecordDefinition" : DestinyRecordDefinition.fromMap,
    "DestinyBondDefinition" : (def)=>def,
    "DestinyDestinationDefinition" : DestinyDestinationDefinition.fromMap,
    "DestinyEquipmentSlotDefinition" : DestinyEquipmentSlotDefinition.fromMap,
    "DestinyInventoryItemDefinition" : DestinyInventoryItemDefinition.fromMap,
    "DestinyLocationDefinition" : DestinyLocationDefinition.fromMap,
    "DestinyLoreDefinition" : DestinyLoreDefinition.fromMap,
    "DestinyObjectiveDefinition" : DestinyObjectiveDefinition.fromMap,
    "DestinyProgressionDefinition" : DestinyProgressionDefinition.fromMap,
    "DestinyProgressionLevelRequirementDefinition" : DestinyProgressionLevelRequirementDefinition.fromMap,
    "DestinySackRewardItemListDefinition" : (def)=>def,
    "DestinySandboxPatternDefinition" : (def)=>def,
    "DestinySocketCategoryDefinition" : DestinySocketCategoryDefinition.fromMap,
    "DestinySocketTypeDefinition" : DestinySocketTypeDefinition.fromMap,
    "DestinyVendorDefinition" : DestinyVendorDefinition.fromMap,
    "DestinyMilestoneDefinition" : DestinyMilestoneDefinition.fromMap,
    "DestinyActivityModifierDefinition" : DestinyActivityModifierDefinition.fromMap,
    "DestinyReportReasonCategoryDefinition" : DestinyReportReasonCategoryDefinition.fromMap,
    "DestinyPlugSetDefinition" : DestinyPlugSetDefinition.fromMap,
    "DestinyChecklistDefinition" : DestinyChecklistDefinition.fromMap,
    "DestinyHistoricalStatsDefinition" : DestinyHistoricalStatsDefinition.fromMap,
  };

  static Map<String, dynamic> classes = {
    "DestinyPlaceDefinition" : DestinyPlaceDefinition,
    "DestinyActivityDefinition" : DestinyActivityDefinition,
    "DestinyActivityTypeDefinition" : DestinyActivityTypeDefinition,
    "DestinyClassDefinition" : DestinyClassDefinition,
    "DestinyGenderDefinition" : DestinyGenderDefinition,
    "DestinyInventoryBucketDefinition" : DestinyInventoryBucketDefinition,
    "DestinyRaceDefinition" : DestinyRaceDefinition,
    "DestinyTalentGridDefinition" : DestinyTalentGridDefinition,
    "DestinyUnlockDefinition" : DestinyUnlockDefinition,
    "DestinyMaterialRequirementSetDefinition" : DestinyMaterialRequirementSetDefinition,
    "DestinySandboxPerkDefinition" : DestinySandboxPerkDefinition,
    "DestinyStatGroupDefinition" : DestinyStatGroupDefinition,
    "DestinyFactionDefinition" : DestinyFactionDefinition,
    "DestinyVendorGroupDefinition" : DestinyVendorGroupDefinition,
    "DestinyRewardSourceDefinition" : DestinyRewardSourceDefinition,
    "DestinyItemCategoryDefinition" : DestinyItemCategoryDefinition,
    "DestinyDamageTypeDefinition" : DestinyDamageTypeDefinition,
    "DestinyActivityModeDefinition" : DestinyActivityModeDefinition,
    "DestinyActivityGraphDefinition" : DestinyActivityGraphDefinition,
    "DestinyCollectibleDefinition" : DestinyCollectibleDefinition,
    "DestinyStatDefinition" : DestinyStatDefinition,
    "DestinyItemTierTypeDefinition" : DestinyItemTierTypeDefinition,
    "DestinyPresentationNodeDefinition" : DestinyPresentationNodeDefinition,
    "DestinyRecordDefinition" : DestinyRecordDefinition,
    "DestinyDestinationDefinition" : DestinyDestinationDefinition,
    "DestinyEquipmentSlotDefinition" : DestinyEquipmentSlotDefinition,
    "DestinyInventoryItemDefinition" : DestinyInventoryItemDefinition,
    "DestinyLocationDefinition" : DestinyLocationDefinition,
    "DestinyLoreDefinition" : DestinyLoreDefinition,
    "DestinyObjectiveDefinition" : DestinyObjectiveDefinition,
    "DestinyProgressionDefinition" : DestinyProgressionDefinition,
    "DestinyProgressionLevelRequirementDefinition" : DestinyProgressionLevelRequirementDefinition,
    "DestinySocketCategoryDefinition" : DestinySocketCategoryDefinition,
    "DestinySocketTypeDefinition" : DestinySocketTypeDefinition,
    "DestinyVendorDefinition" : DestinyVendorDefinition,
    "DestinyMilestoneDefinition" : DestinyMilestoneDefinition,
    "DestinyActivityModifierDefinition" : DestinyActivityModifierDefinition,
    "DestinyReportReasonCategoryDefinition" : DestinyReportReasonCategoryDefinition,
    "DestinyPlugSetDefinition" : DestinyPlugSetDefinition,
    "DestinyChecklistDefinition" : DestinyChecklistDefinition,
    "DestinyHistoricalStatsDefinition" : DestinyHistoricalStatsDefinition,
  };
}
