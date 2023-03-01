// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_properties.mixin.dart';
import 'package:shimmer/shimmer.dart';

class MediumSubclassInventoryItemWidget extends MediumBaseInventoryItemWidget
    with SubclassPropertiesMixin, ProfileConsumer {
  MediumSubclassInventoryItemWidget(
    DestinyItemComponent item,
    DestinyInventoryItemDefinition definition,
    DestinyItemInstanceComponent instanceInfo, {
    @required String characterId,
    Key key,
    @required String uniqueId,
  }) : super(item, definition, instanceInfo,
            characterId: characterId, key: key, uniqueId: uniqueId);

  @override
  double get iconSize {
    return 68;
  }

  @override
  background(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
        gradient: RadialGradient(
      radius: 2,
      center: const Alignment(1, 0),
      colors: <Color>[
        startBgColor(context),
        Colors.transparent,
        endBgColor(context),
      ],
      stops: const [0, .3, .8],
    ));
    return Positioned.fill(
      child: Container(
          decoration: decoration,
          child: Transform.translate(
              offset: Offset(15, 0),
              child: Container(
                  foregroundDecoration: decoration,
                  child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    item.itemHash,
                    urlExtractor: (def) => def.screenshot,
                    alignment: Alignment.centerRight,
                    fit: BoxFit.fitHeight,
                    placeholder: Shimmer.fromColors(
                      baseColor: endBgColor(context),
                      highlightColor: startBgColor(context),
                      child: Container(color: Colors.white),
                    ),
                  )))),
    );
  }

  @override
  Widget positionedNameBar(BuildContext context) {
    return Container();
  }

  @override
  double get padding {
    return 4;
  }

  @override
  Widget perksWidget(BuildContext context) {
    return Container();
  }

  @override
  Widget modsWidget(BuildContext context) {
    return Container();
  }

  @override
  Widget primaryStatWidget(BuildContext context) {
    return Container();
  }
}
