import 'package:bungie_api/models/destiny_milestone_reward_entry_definition.dart';
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
  static Map<Type, Function> identities = {
    DestinyPlaceDefinition: DestinyPlaceDefinition.fromMap,
    DestinyActivityDefinition: DestinyActivityDefinition.fromMap,
    DestinyActivityTypeDefinition: DestinyActivityTypeDefinition.fromMap,
    DestinyClassDefinition: DestinyClassDefinition.fromMap,
    DestinyGenderDefinition: DestinyGenderDefinition.fromMap,
    DestinyInventoryBucketDefinition: DestinyInventoryBucketDefinition.fromMap,
    DestinyRaceDefinition: DestinyRaceDefinition.fromMap,
    DestinyTalentGridDefinition: DestinyTalentGridDefinition.fromMap,
    DestinyUnlockDefinition: DestinyUnlockDefinition.fromMap,
    DestinyMaterialRequirementSetDefinition:DestinyMaterialRequirementSetDefinition.fromMap,
    DestinySandboxPerkDefinition: DestinySandboxPerkDefinition.fromMap,
    DestinyStatGroupDefinition: DestinyStatGroupDefinition.fromMap,
    DestinyFactionDefinition: DestinyFactionDefinition.fromMap,
    DestinyVendorGroupDefinition: DestinyVendorGroupDefinition.fromMap,
    DestinyRewardSourceDefinition: DestinyRewardSourceDefinition.fromMap,
    DestinyItemCategoryDefinition: DestinyItemCategoryDefinition.fromMap,
    DestinyDamageTypeDefinition: DestinyDamageTypeDefinition.fromMap,
    DestinyActivityModeDefinition: DestinyActivityModeDefinition.fromMap,
    DestinyActivityGraphDefinition: DestinyActivityGraphDefinition.fromMap,
    DestinyCollectibleDefinition: DestinyCollectibleDefinition.fromMap,
    DestinyStatDefinition: DestinyStatDefinition.fromMap,
    DestinyItemTierTypeDefinition: DestinyItemTierTypeDefinition.fromMap,
    DestinyPresentationNodeDefinition:DestinyPresentationNodeDefinition.fromMap,
    DestinyRecordDefinition: DestinyRecordDefinition.fromMap,
    DestinyDestinationDefinition: DestinyDestinationDefinition.fromMap,
    DestinyEquipmentSlotDefinition: DestinyEquipmentSlotDefinition.fromMap,
    DestinyInventoryItemDefinition: DestinyInventoryItemDefinition.fromMap,
    DestinyLocationDefinition: DestinyLocationDefinition.fromMap,
    DestinyLoreDefinition: DestinyLoreDefinition.fromMap,
    DestinyObjectiveDefinition: DestinyObjectiveDefinition.fromMap,
    DestinyProgressionDefinition: DestinyProgressionDefinition.fromMap,
    DestinyProgressionLevelRequirementDefinition:DestinyProgressionLevelRequirementDefinition.fromMap,
    DestinySocketCategoryDefinition: DestinySocketCategoryDefinition.fromMap,
    DestinySocketTypeDefinition: DestinySocketTypeDefinition.fromMap,
    DestinyVendorDefinition: DestinyVendorDefinition.fromMap,
    DestinyMilestoneDefinition: DestinyMilestoneDefinition.fromMap,
    DestinyActivityModifierDefinition:DestinyActivityModifierDefinition.fromMap,
    DestinyReportReasonCategoryDefinition:DestinyReportReasonCategoryDefinition.fromMap,
    DestinyPlugSetDefinition: DestinyPlugSetDefinition.fromMap,
    DestinyChecklistDefinition: DestinyChecklistDefinition.fromMap,
    DestinyHistoricalStatsDefinition: DestinyHistoricalStatsDefinition.fromMap,
    DestinyMilestoneRewardEntryDefinition: DestinyMilestoneRewardEntryDefinition.fromMap
  };

  static Map<Type, String> fromClass = {
    DestinyPlaceDefinition: "DestinyPlaceDefinition",
    DestinyActivityDefinition: "DestinyActivityDefinition",
    DestinyActivityTypeDefinition: "DestinyActivityTypeDefinition",
    DestinyClassDefinition: "DestinyClassDefinition",
    DestinyGenderDefinition: "DestinyGenderDefinition",
    DestinyInventoryBucketDefinition: "DestinyInventoryBucketDefinition",
    DestinyRaceDefinition: "DestinyRaceDefinition",
    DestinyTalentGridDefinition: "DestinyTalentGridDefinition",
    DestinyUnlockDefinition: "DestinyUnlockDefinition",
    DestinyMaterialRequirementSetDefinition:
        "DestinyMaterialRequirementSetDefinition",
    DestinySandboxPerkDefinition: "DestinySandboxPerkDefinition",
    DestinyStatGroupDefinition: "DestinyStatGroupDefinition",
    DestinyFactionDefinition: "DestinyFactionDefinition",
    DestinyVendorGroupDefinition: "DestinyVendorGroupDefinition",
    DestinyRewardSourceDefinition: "DestinyRewardSourceDefinition",
    DestinyItemCategoryDefinition: "DestinyItemCategoryDefinition",
    DestinyDamageTypeDefinition: "DestinyDamageTypeDefinition",
    DestinyActivityModeDefinition: "DestinyActivityModeDefinition",
    DestinyActivityGraphDefinition: "DestinyActivityGraphDefinition",
    DestinyCollectibleDefinition: "DestinyCollectibleDefinition",
    DestinyStatDefinition: "DestinyStatDefinition",
    DestinyItemTierTypeDefinition: "DestinyItemTierTypeDefinition",
    DestinyPresentationNodeDefinition: "DestinyPresentationNodeDefinition",
    DestinyRecordDefinition: "DestinyRecordDefinition",
    DestinyDestinationDefinition: "DestinyDestinationDefinition",
    DestinyEquipmentSlotDefinition: "DestinyEquipmentSlotDefinition",
    DestinyInventoryItemDefinition: "DestinyInventoryItemDefinition",
    DestinyLocationDefinition: "DestinyLocationDefinition",
    DestinyLoreDefinition: "DestinyLoreDefinition",
    DestinyObjectiveDefinition: "DestinyObjectiveDefinition",
    DestinyProgressionDefinition: "DestinyProgressionDefinition",
    DestinyProgressionLevelRequirementDefinition:
        "DestinyProgressionLevelRequirementDefinition",
    DestinySocketCategoryDefinition: "DestinySocketCategoryDefinition",
    DestinySocketTypeDefinition: "DestinySocketTypeDefinition",
    DestinyVendorDefinition: "DestinyVendorDefinition",
    DestinyMilestoneDefinition: "DestinyMilestoneDefinition",
    DestinyActivityModifierDefinition: "DestinyActivityModifierDefinition",
    DestinyReportReasonCategoryDefinition:
        "DestinyReportReasonCategoryDefinition",
    DestinyPlugSetDefinition: "DestinyPlugSetDefinition",
    DestinyChecklistDefinition: "DestinyChecklistDefinition",
    DestinyHistoricalStatsDefinition: "DestinyHistoricalStatsDefinition",
    DestinyMilestoneRewardEntryDefinition: "DestinyMilestoneRewardEntryDefinition"
  };
}
