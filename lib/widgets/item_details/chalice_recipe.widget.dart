// @dart=2.9

import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/utils/chalice_recipes.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:url_launcher/url_launcher.dart';

enum TestEnum { A, B, C, D }

class ChaliceRecipeWidget extends StatelessWidget {
  final DestinyInventoryItemDefinition definition;

  ChaliceRecipeWidget(this.definition, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ChaliceRecipe recipe = ChaliceRecipe.get(definition.hash);
    if (recipe == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(children: [
        HeaderWidget(
            child: Container(
          alignment: Alignment.centerLeft,
          child: TranslatedTextWidget(
            "Chalice Recipes",
            uppercase: true,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )),
        buildSlots(context, recipe),
        buildBraytechNote(context)
      ]),
    );
  }

  buildBraytechNote(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Row(
          children: <Widget>[
            Text("More recipes on".translate(context)),
            MaterialButton(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(children: [
                Container(
                  margin: EdgeInsets.only(right: 8),
                  width: 16,
                  height: 16,
                  child: Image.asset("assets/imgs/braytech_icon.png"),
                ),
                Text('braytech.org')
              ]),
              onPressed: () {
                launch("https://braytech.org/chalice-tool");
              },
            )
          ],
        ));
  }

  Widget buildSlots(BuildContext context, ChaliceRecipe recipe) {
    if (MediaQueryHelper(context).tabletOrBigger) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: buildTopSlot(context, recipe)),
          Container(
            width: 4,
          ),
          Expanded(child: buildLeftSlot(context, recipe)),
          Container(
            width: 4,
          ),
          Expanded(child: buildRightSlot(context, recipe)),
        ],
      );
    }
    return Column(
      children: <Widget>[
        buildTopSlot(context, recipe),
        buildLeftSlot(context, recipe),
        buildRightSlot(context, recipe)
      ],
    );
  }

  Widget buildSlotHeader(BuildContext context, Widget title) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      child: title,
    );
  }

  Widget buildTopSlot(BuildContext context, ChaliceRecipe recipe) {
    return Column(children: [
      buildSlotHeader(
          context,
          TranslatedTextWidget(
            "Top",
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      buildRuneItem(context, recipe.top)
    ]);
  }

  Widget buildLeftSlot(BuildContext context, ChaliceRecipe recipe) {
    return Column(
        children: [
      buildSlotHeader(
          context,
          TranslatedTextWidget(
            "Left",
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    ].followedBy(recipe.left.map((r) => buildRuneItem(context, r, RunePosition.Left))).toList());
  }

  Widget buildRightSlot(BuildContext context, ChaliceRecipe recipe) {
    return Column(
        children: [
      buildSlotHeader(
          context,
          TranslatedTextWidget(
            "Right",
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    ].followedBy(recipe.right.map((r) => buildRuneItem(context, r, RunePosition.Right))).toList());
  }

  Color getBackgroundColor(RuneColor color) {
    switch (color) {
      case RuneColor.Purple:
        return Color.fromRGBO(53, 44, 86, 1);
        break;
      case RuneColor.Red:
        return Color.fromRGBO(72, 27, 36, 1);
        break;
      case RuneColor.Green:
        return Color.fromRGBO(64, 121, 93, 1);
        break;
      case RuneColor.Blue:
        return Color.fromRGBO(19, 51, 59, 1);
        break;
    }
    return null;
  }

  Widget buildRuneItem(BuildContext context, RuneInfo rune, [RunePosition position = RunePosition.Top]) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber.shade100.withOpacity(.5), width: 1),
        color: getBackgroundColor(rune.color),
      ),
      child: Row(
        children: <Widget>[
          Container(
              width: 64,
              height: 64,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(rune.itemHash ?? 1772646107)),
          buildModifierIcon(context, rune, position),
          Container(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildRuneTitle(context, rune),
              buildModifierText(context, rune, position),
            ],
          )
        ],
      ),
    );
  }

  int getArmorModifierIconHash(ArmorIntrinsics armorPerk) {
    switch (armorPerk) {
      case ArmorIntrinsics.Mobility:
        return 1633794450;
      case ArmorIntrinsics.Recovery:
        return 2032054360;
      case ArmorIntrinsics.Resilience:
        return 3530997750;
    }
    return 1772646107;
  }

  int getArmorMasterworkIconHash(DamageType damageType) {
    switch (damageType) {
      case DamageType.Arc:
        return 3130025796;
      case DamageType.Thermal:
        return 3789923095;
      case DamageType.Void:
        return 1576279482;
      default:
        return 1456563170;
    }
  }

  int getWeaponMasterworkIconHash(WeaponMasterwork type) {
    switch (type) {
      case WeaponMasterwork.Handling:
        return 2357520979;
        break;
      case WeaponMasterwork.Reload:
        return 758092021;
        break;
      case WeaponMasterwork.Range:
        return 684616255;
        break;
      case WeaponMasterwork.Stability:
        return 384158423;
    }
    return 0;
  }

  int getArmorModifierTextHash(ArmorIntrinsics armorPerk) {
    switch (armorPerk) {
      case ArmorIntrinsics.Mobility:
        return [1248391073, 2114652868, 3800753361][definition.classType.value];
      case ArmorIntrinsics.Recovery:
        return [1466306887, 1779420771, 1899914236][definition.classType.value];
      case ArmorIntrinsics.Resilience:
        return [3404948861, 3551200371, 1097521167][definition.classType.value];
    }
    return 0;
  }

  int getArmorMasterworkTextHash(DamageType type) {
    switch (type) {
      case DamageType.Arc:
        return 1980826824;
      case DamageType.Thermal:
        return 3552519857;
      case DamageType.Void:
        return 3853494024;
      default:
        return null;
    }
  }

  int getWeaponMasterworkTextHash(WeaponMasterwork type) {
    switch (type) {
      case WeaponMasterwork.Handling:
        return 943549884;
        break;
      case WeaponMasterwork.Reload:
        return 4188031367;
        break;
      case WeaponMasterwork.Range:
        return 1240592695;
        break;
      case WeaponMasterwork.Stability:
        return 155624089;
    }
    return 0;
  }

  Widget buildModifierIcon(BuildContext context, RuneInfo rune, RunePosition position) {
    if (position == RunePosition.Left && definition.itemType == DestinyItemType.Armor) {
      return Container(
        margin: EdgeInsets.only(left: 4),
        width: 56,
        height: 48,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(getArmorModifierIconHash(rune.armorPerk)),
      );
    }
    if (position == RunePosition.Right && definition.itemType == DestinyItemType.Armor) {
      return Container(
        width: 56,
        height: 56,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            getArmorMasterworkIconHash(rune.armorMasterworkDamageType)),
      );
    }
    if (position == RunePosition.Right && definition.itemType == DestinyItemType.Weapon) {
      return Container(
        width: 56,
        height: 56,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(getWeaponMasterworkIconHash(rune.weaponMasterwork)),
      );
    }
    return Container();
  }

  Widget buildModifierText(BuildContext context, RuneInfo rune, RunePosition position) {
    if (position == RunePosition.Left && definition.itemType == DestinyItemType.Armor) {
      return Container(
          margin: EdgeInsets.only(top: 4),
          child: ManifestText<DestinyInventoryItemDefinition>(getArmorModifierTextHash(rune.armorPerk)));
    }
    if (position == RunePosition.Right && definition.itemType == DestinyItemType.Armor) {
      return Container(
          margin: EdgeInsets.only(top: 4),
          child:
              ManifestText<DestinySandboxPerkDefinition>(getArmorMasterworkTextHash(rune.armorMasterworkDamageType)));
    }
    if (position == RunePosition.Right && definition.itemType == DestinyItemType.Weapon) {
      return Container(
          margin: EdgeInsets.only(top: 4),
          child: ManifestText<DestinyStatDefinition>(getWeaponMasterworkTextHash(rune.weaponMasterwork)));
    }
    return Container();
  }

  Widget buildRuneTitle(BuildContext context, RuneInfo rune) {
    if (rune.itemHash != null) {
      return ManifestText<DestinyInventoryItemDefinition>(rune.itemHash, style: TextStyle(fontWeight: FontWeight.bold));
    }
    switch (rune.color) {
      case RuneColor.Purple:
        return TranslatedTextWidget(
          "Any Purple rune",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      case RuneColor.Red:
        return Text("Any Red rune".translate(context), style: TextStyle(fontWeight: FontWeight.bold));
        break;
      case RuneColor.Green:
        return Text("Any Green rune".translate(context), style: TextStyle(fontWeight: FontWeight.bold));
        break;
      case RuneColor.Blue:
        return Text("Any Blue rune".translate(context), style: TextStyle(fontWeight: FontWeight.bold));
        break;
    }
    return Container();
  }
}
