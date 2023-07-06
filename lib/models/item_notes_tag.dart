import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:uuid/uuid.dart';

part 'item_notes_tag.g.dart';

enum ItemTagIcon {
  Heart,
  Star,
  Infuse,
  Resources,
  Trash,
  ThumbsUp,
  ThumbsDown,
  Vanguard,
  Vanguard2,
  Crucible,
  Crucible2,
  Gambit,
  Raid,
  IronBanner,
  Osiris,
  Titan,
  Hunter,
  Warlock,
  Kinetic,
  Arc,
  Thermal,
  Void,
  Pierce,
  Overload,
  Stagger,
  Mobility,
  Resilience,
  Recovery,
  Intellect,
  Discipline,
  Strength,
  Sentry,
  Reaper,
  Invader,
  Collector,
  BlockerSmall,
  BlockerMedium,
  BlockerLarge,
  BlockerGiant,
}

extension ItemTagIconData on ItemTagIcon {
  IconData? get iconData => tagIconData[this];
}

extension DefaultTagTypeLabel on DefaultTagType {
  String getLabel(BuildContext context) {
    switch (this) {
      case DefaultTagType.Favorite:
        return "Favorite".translate(context);
      case DefaultTagType.Trash:
        return "Trash".translate(context);
      case DefaultTagType.Infuse:
        return "Infuse".translate(context);
    }
  }
}

enum DefaultTagType {
  Favorite,
  Trash,
  Infuse,
}

const Map<ItemTagIcon, IconData> tagIconData = {
  ItemTagIcon.Heart: FontAwesomeIcons.solidHeart,
  ItemTagIcon.Star: FontAwesomeIcons.solidStar,
  ItemTagIcon.Infuse: LittleLightIcons.infuse,
  ItemTagIcon.Resources: LittleLightIcons.resources,
  ItemTagIcon.Trash: Icons.delete,
  ItemTagIcon.ThumbsUp: FontAwesomeIcons.solidThumbsUp,
  ItemTagIcon.ThumbsDown: FontAwesomeIcons.solidThumbsDown,
  ItemTagIcon.Vanguard: LittleLightIcons.vanguard,
  ItemTagIcon.Vanguard2: LittleLightIcons.vanguard2,
  ItemTagIcon.Crucible: LittleLightIcons.crucible,
  ItemTagIcon.Crucible2: LittleLightIcons.crucible2,
  ItemTagIcon.Gambit: LittleLightIcons.gambit,
  ItemTagIcon.Raid: LittleLightIcons.raid,
  ItemTagIcon.IronBanner: LittleLightIcons.ironbanner,
  ItemTagIcon.Osiris: LittleLightIcons.osiris,
  ItemTagIcon.Titan: LittleLightIcons.class_titan,
  ItemTagIcon.Hunter: LittleLightIcons.class_hunter,
  ItemTagIcon.Warlock: LittleLightIcons.class_warlock,
  ItemTagIcon.Kinetic: LittleLightIcons.damage_kinetic,
  ItemTagIcon.Arc: LittleLightIcons.damage_arc,
  ItemTagIcon.Thermal: LittleLightIcons.damage_solar,
  ItemTagIcon.Void: LittleLightIcons.damage_void,
  ItemTagIcon.Pierce: LittleLightIcons.pierce,
  ItemTagIcon.Overload: LittleLightIcons.overload,
  ItemTagIcon.Stagger: LittleLightIcons.stagger,
  ItemTagIcon.Mobility: LittleLightIcons.mobility,
  ItemTagIcon.Resilience: LittleLightIcons.resilience,
  ItemTagIcon.Recovery: LittleLightIcons.recovery,
  ItemTagIcon.Intellect: LittleLightIcons.intellect,
  ItemTagIcon.Discipline: LittleLightIcons.discipline,
  ItemTagIcon.Strength: LittleLightIcons.strength,
  ItemTagIcon.Sentry: LittleLightIcons.gambit_sentry,
  ItemTagIcon.Reaper: LittleLightIcons.gambit_reaper,
  ItemTagIcon.Invader: LittleLightIcons.gambit_invader,
  ItemTagIcon.Collector: LittleLightIcons.gambit_collector,
  ItemTagIcon.BlockerSmall: LittleLightIcons.blocker_small,
  ItemTagIcon.BlockerMedium: LittleLightIcons.blocker_medium,
  ItemTagIcon.BlockerLarge: LittleLightIcons.blocker_large,
  ItemTagIcon.BlockerGiant: LittleLightIcons.blocker_giant
};

@JsonSerializable()
class ItemNotesTag {
  bool custom;
  String? tagId;
  String name;
  String backgroundColorHex;
  String foregroundColorHex;
  ItemTagIcon icon;
  DefaultTagType? defaultTagType;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  Color? get backgroundColor {
    return colorFromHex(backgroundColorHex);
  }

  Color? get foregroundColor {
    return colorFromHex(foregroundColorHex);
  }

  IconData? get iconData {
    return tagIconData[icon];
  }

  ItemNotesTag({
    this.custom = false,
    this.tagId,
    this.name = "",
    this.backgroundColorHex = "#00000000",
    this.foregroundColorHex = "#FFFFFFFF",
    this.defaultTagType,
    this.icon = ItemTagIcon.Star,
    this.updatedAt,
  });

  factory ItemNotesTag.fromJson(dynamic json) {
    return _$ItemNotesTagFromJson(json);
  }

  factory ItemNotesTag.favorite() {
    return ItemNotesTag(
      tagId: "favorite",
      icon: ItemTagIcon.Heart,
      defaultTagType: DefaultTagType.Favorite,
      backgroundColorHex: hexFromColor(Colors.yellow.shade800),
      foregroundColorHex: hexFromColor(LittleLightThemeData().onSurfaceLayers),
    );
  }

  factory ItemNotesTag.trash() {
    return ItemNotesTag(
      tagId: "trash",
      icon: ItemTagIcon.Trash,
      defaultTagType: DefaultTagType.Trash,
      backgroundColorHex: hexFromColor(Colors.red.shade700),
      foregroundColorHex: hexFromColor(LittleLightThemeData().onSurfaceLayers),
    );
  }

  factory ItemNotesTag.infuse() {
    return ItemNotesTag(
      tagId: "infuse",
      icon: ItemTagIcon.Infuse,
      defaultTagType: DefaultTagType.Infuse,
      backgroundColorHex: hexFromColor(Colors.grey.shade900),
      foregroundColorHex: hexFromColor(Colors.amber.shade300),
    );
  }

  factory ItemNotesTag.newCustom() {
    return ItemNotesTag(tagId: const Uuid().v4(), custom: true);
  }

  dynamic toJson() {
    return _$ItemNotesTagToJson(this);
  }

  ItemNotesTag clone() => ItemNotesTag.fromJson(toJson());
}
