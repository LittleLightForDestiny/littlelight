import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';

class CollectibleItemWidget extends StatelessWidget {
  final int? collectibleHash;
  final DestinyItemInfo? genericItem;
  final List<DestinyItemInfo>? items;
  final bool isUnlocked;
  const CollectibleItemWidget(
    this.collectibleHash, {
    Key? key,
    this.items,
    this.genericItem,
    this.isUnlocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SelectionBloc>();
    final items = this.items;
    final selected = items != null && items.isNotEmpty && items.every((i) => selection.isItemSelected(i));
    return Opacity(
        opacity: isUnlocked ? 1 : .4,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: context.theme.surfaceLayers.layer3, width: 1),
                gradient: LinearGradient(begin: const Alignment(0, 0), end: const Alignment(1, 2), colors: [
                  context.theme.onSurfaceLayers.withOpacity(.05),
                  context.theme.onSurfaceLayers.withOpacity(.1),
                  context.theme.onSurfaceLayers.withOpacity(.03),
                  context.theme.onSurfaceLayers.withOpacity(.1)
                ])),
            child: Stack(children: [
              buildItem(context),
              Positioned(right: 4, top: 4, child: Row(children: [buildUnavailable(context), buildItemCount(context)])),
              Positioned.fill(
                  child: InteractiveItemWrapper(
                Container(),
                item: genericItem,
                overrideSelection: selected,
              )),
            ])));
  }

  Widget buildItem(BuildContext context) {
    final genericItem = this.genericItem;
    if (genericItem != null) {
      return HighDensityInventoryItem(genericItem);
    }
    final definition = context.definition<DestinyCollectibleDefinition>(collectibleHash);
    return Container(
      padding: EdgeInsets.all(4),
      child: Row(children: [
        buildIcon(context),
        Container(
          alignment: Alignment.center,
          child: Text(
            definition?.displayProperties?.name ?? "Redacted".translate(context),
            style: context.textTheme.itemNameHighDensity,
          ),
        ),
      ]),
    );
  }

  Widget buildIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      color: context.theme.onSurfaceLayers.layer1,
      margin: EdgeInsets.only(right: 8),
      width: 88,
      height: 88,
      child: ManifestImageWidget<DestinyCollectibleDefinition>(collectibleHash),
    );
  }

  Widget buildItemCount(BuildContext context) {
    final total = items?.length ?? 0;
    if (total == 0) {
      return Container();
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.onSurfaceLayers,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
        color: context.theme.surfaceLayers.layer2.withOpacity(.8),
      ),
      alignment: Alignment.center,
      child: Text(
        "${total}",
        textAlign: TextAlign.center,
        style: context.textTheme.highlight,
      ),
    );
  }

  Widget buildUnavailable(BuildContext context) {
    final def = context.read<ProfileBloc>().getProfileCollectible(collectibleHash);
    if (def?.state?.contains(DestinyCollectibleState.Invisible) ?? false) {
      return Container(
          width: 24,
          height: 24, //
          child: Icon(Icons.block, color: context.theme.highlightedObjectiveLayers));
    }
    return Container();
  }
}
