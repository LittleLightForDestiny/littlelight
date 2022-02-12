// @dart=2.9

import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_talent_node_category.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/profile/profile.consumer.dart';

class SubclassTalentGridInfo {
  DamageType damageType;
  int mainPerkHash;
  int grenadePerkHash;
  int jumpPerkHash;
  int classSkillPerkHash;

  SubclassTalentGridInfo(
      {this.damageType,
      this.mainPerkHash,
      this.grenadePerkHash,
      this.jumpPerkHash,
      this.classSkillPerkHash});
}

const Map<String, int> _subclassMainPerks = {
  //titan solar
  "titan_solar_firstpath": 3955302463,
  "titan_solar_secondpath": 2401205106,
  "titan_solar_thirdpath": 461974996,
  //titan arc
  "titan_arc_firstpath": 3720167252,
  "titan_arc_secondpath": 3326771373,
  "titan_arc_thirdpath": 2918527423,
  //titan void
  "titan_void_firstpath": 3170765412,
  "titan_void_secondpath": 3112248479,
  "titan_void_thirdpath": 3471252175,
  //titan stasis
  "titan_stasis": 1720064609,

  //hunter solar
  "hunter_solar_firstpath": 3165122177,
  "hunter_solar_secondpath": 2041340886,
  "hunter_solar_thirdpath": 2265198010,
  //hunter arc
  "hunter_arc_firstpath": 914737202,
  "hunter_arc_secondpath": 2236497009,
  "hunter_arc_thirdpath": 1302127157,
  //hunter void
  "hunter_void_firstpath": 423378447,
  "hunter_void_secondpath": 4099200371,
  "hunter_void_thirdpath": 3566763565,
  //hunter stasis
  "hunter_stasis": 2115357203,

  //warlock solar
  "warlock_solar_firstpath": 1887222240,
  "warlock_solar_secondpath": 1267155257,
  "warlock_solar_thirdpath": 4050937691,
  //warlock arc
  "warlock_arc_firstpath": 3972661583,
  "warlock_arc_secondpath": 3368836162,
  "warlock_arc_thirdpath": 4087094734,
  //warlock void
  "warlock_void_firstpath": 195170165,
  "warlock_void_secondpath": 3247948194,
  "warlock_void_thirdpath": 3959434990,
  //warlock stasis
  "warlock_stasis": 1507879500,
};

Future<SubclassTalentGridInfo> getSubclassTalentGridInfo(
    DestinyItemComponent item) async {
  final profile = getInjectedProfileService();
  final manifest = getInjectedManifestService();
  var def = await manifest
      .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
  var talentGrid = profile.getTalentGrid(item?.itemInstanceId);
  var talentGridDef = await manifest
      .getDefinition<DestinyTalentGridDefinition>(talentGrid.talentGridHash);
  var talentgridCategory =
      extractTalentGridNodeCategory(talentGridDef, talentGrid);
  var mainPerk = getSubclassMainPerk(def, talentgridCategory);

  return SubclassTalentGridInfo(
      mainPerkHash: mainPerk, damageType: def.talentGrid.hudDamageType);
}

int getSubclassMainPerk(DestinyInventoryItemDefinition def,
    DestinyTalentNodeCategory talentgridCategory) {
  var str = "";
  switch (def.classType) {
    case DestinyClass.Titan:
      str += "titan";
      break;
    case DestinyClass.Hunter:
      str += "hunter";
      break;
    case DestinyClass.Warlock:
      str += "warlock";
      break;
    default:
      return null;
  }
  switch (def?.talentGrid?.hudDamageType) {
    case DamageType.Arc:
      str += "_arc";
      break;
    case DamageType.Thermal:
      str += "_solar";
      break;
    case DamageType.Void:
      str += "_void";
      break;
    case DamageType.Stasis:
      str += "_stasis";
      break;
    default:
      return null;
      break;
  }
  if ((talentgridCategory?.identifier?.length ?? 0) > 0) {
    str += "_${talentgridCategory.identifier}";
  }

  if (_subclassMainPerks.containsKey(str)) {
    return _subclassMainPerks[str];
  }
  return null;
}

DestinyTalentNodeCategory extractTalentGridNodeCategory(
    DestinyTalentGridDefinition talentGridDef,
    DestinyItemTalentGridComponent talentGrid) {
  Iterable<int> activatedNodes = talentGrid?.nodes
      ?.where((node) => node.isActivated)
      ?.map((node) => node.nodeIndex);
  Iterable<DestinyTalentNodeCategory> selectedSkills =
      talentGridDef?.nodeCategories?.where((category) {
    var overlapping = category.nodeHashes
        .where((nodeHash) => activatedNodes?.contains(nodeHash) ?? false);
    return overlapping.length > 0;
  })?.toList();
  DestinyTalentNodeCategory subclassPath = selectedSkills
      ?.firstWhere((nodeDef) => nodeDef.isLoreDriven, orElse: () => null);
  return subclassPath;
}
