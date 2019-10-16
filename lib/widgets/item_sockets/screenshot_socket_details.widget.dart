import 'package:bungie_api/enums/destiny_energy_type_enum.dart';
import 'package:bungie_api/enums/item_perk_visibility_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_energy_type_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_stats/screenshot_socket_item_stats.widget.dart';

class ScreenshotSocketDetailsWidget extends BaseSocketDetailsWidget {
  final ItemSocketController controller;
  final double pixelSize;
  ScreenshotSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition parentDefinition,
      this.controller,
      this.pixelSize})
      : super(item: item, definition: parentDefinition);

  @override
  _ScreenshotPerkDetailsWidgetState createState() =>
      _ScreenshotPerkDetailsWidgetState();
}

class _ScreenshotPerkDetailsWidgetState
    extends BaseSocketDetailsWidgetState<ScreenshotSocketDetailsWidget> {
  int _currentPage = 0;
  ItemSocketController get controller => widget.controller;
  DestinyInventoryItemDefinition _definition;
  DestinyInventoryItemDefinition get definition => _definition;
  DestinyInventoryItemDefinition get itemDefinition => widget.definition;
  Map<int, DestinySandboxPerkDefinition> _sandboxPerkDefinitions;
  int armorEnergyType;

  @override
  void initState() {
    controller.addListener(socketChanged);
    super.initState();
  }

  void dispose() {
    controller.removeListener(socketChanged);
    super.dispose();
  }

  socketChanged() async {
    await this.loadDefinitions();
  }

  @override
  loadDefinitions() async {
    super.loadDefinitions();
    if ((controller.selectedPlugHash ?? 0) == 0) {
      _definition = null;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(
            controller.selectedPlugHash);
    _sandboxPerkDefinitions = await widget.manifest
        .getDefinitions<DestinySandboxPerkDefinition>(
            _definition?.perks?.map((p) => p.perkHash)?.toList() ?? []);

    super.loadDefinitions();
  }

  @override
  Widget build(BuildContext context) {
    if (_definition == null) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildOptions(context),
          Container(
            height: widget.pixelSize * 16,
          ),
          Container(
            height: widget.pixelSize * 5,
            color: Colors.grey.shade400,
          ),
          Container(
              padding: EdgeInsets.all(16 * widget.pixelSize),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    definition?.displayProperties?.name?.toUpperCase(),
                    style: TextStyle(
                        fontSize: 30 * widget.pixelSize,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(definition?.itemTypeDisplayName,
                      style: TextStyle(
                          fontSize: 24 * widget.pixelSize,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w300))
                ],
              )),
          Container(
              padding: EdgeInsets.all(16 * widget.pixelSize),
              color: Colors.black.withOpacity(.7),
              child: buildContent(context))
        ]);
  }

  Widget buildOptions(BuildContext context) {
    var index = controller.selectedSocketIndex;
    var cat = itemDefinition?.sockets?.socketCategories?.firstWhere(
        (s) => s?.socketIndexes?.contains(index),
        orElse: () => null);
    var isPerk =
        DestinyData.socketCategoryPerkHashes.contains(cat?.socketCategoryHash);
    if (isPerk) {
      return buildRandomPerks(context);
    }
    return buildReusableMods(context);
  }

  Widget buildReusableMods(BuildContext context) {
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    int maxPage = ((plugs.length - 1) / 10).floor();
    var page = _currentPage.clamp(0, maxPage);
    _currentPage = page;
    return IntrinsicHeight(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      pagingButton(context, -1, page > 0),
      Container(
          width: 520 * widget.pixelSize,
          child: Wrap(
            runSpacing: 10 * widget.pixelSize,
            spacing: 10 * widget.pixelSize,
            children: plugs
                .skip(page * 10)
                .take(10)
                .map(
                    (h) => buildMod(context, controller.selectedSocketIndex, h))
                .toList(),
          )),
      pagingButton(context, 1, page < maxPage),
    ]));
  }

  Widget pagingButton(BuildContext context,
      [int direction = 1, bool enabled = false]) {
    return Container(
      constraints: BoxConstraints.expand(width: 32 * widget.pixelSize),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
      padding: EdgeInsets.all(0),
      alignment: Alignment.center,
      child: !enabled
          ? Container(color: Colors.grey.shade300.withOpacity(.2))
          : Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                    if (!enabled) return;
                    _currentPage += direction;
                    setState(() {});
                  },
                  child: Container(
                      constraints: BoxConstraints.expand(),
                      child: Icon(
                          direction > 0
                              ? FontAwesomeIcons.caretRight
                              : FontAwesomeIcons.caretLeft,
                          size: 30 * widget.pixelSize)))),
    );
  }

  Widget buildRandomPerks(BuildContext context) {
    var randomHashes =
        controller.randomizedPlugHashes(controller.selectedSocketIndex);
    if ((randomHashes?.length ?? 0) == 0) {
      return Container(height: 80 * widget.pixelSize);
    }
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    plugs.addAll(randomHashes);
    return Wrap(
      runSpacing: 6 * widget.pixelSize,
      spacing: 6 * widget.pixelSize,
      children: plugs
          .map((h) => buildPerk(context, controller.selectedSocketIndex, h))
          .toList(),
    );
  }

  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color borderColor =
        isSelected ? Colors.white : Colors.grey.shade300.withOpacity(.5);

    BorderSide borderSide =
        BorderSide(color: borderColor, width: 3 * widget.pixelSize);
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    return Container(
        width: 96 * widget.pixelSize,
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: FlatButton(
              shape: ContinuousRectangleBorder(side: borderSide),
              padding: EdgeInsets.all(0),
              child: Stack(children: [
                ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugItemHash),
                energyType == DestinyEnergyType.Any
                    ? Container()
                    : Positioned(
                        top: 8 * widget.pixelSize,
                        right: 8 * widget.pixelSize,
                        child: Icon(
                          DestinyData.getEnergyTypeIcon(energyType),
                          size: 24 * widget.pixelSize,
                          color: DestinyData.getEnergyTypeColor(energyType),
                        ))
              ]),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    var plugDef = controller.plugDefinitions[plugItemHash];
    bool intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isExotic = definition.inventory.tierType == TierType.Exotic;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300.withOpacity(.5);
    if (isEquipped && !intrinsic) {
      bgColor = DestinyData.perkColor.withOpacity(.5);
    }
    if (isSelectedOnSocket && !intrinsic) {
      bgColor = DestinyData.perkColor;
      borderColor = Colors.grey.shade300;
    }

    if (intrinsic && !isSelected) {
      borderColor = Colors.transparent;
    }

    BorderSide borderSide =
        BorderSide(color: borderColor, width: 2 * widget.pixelSize);

    return Container(
        width: 80 * widget.pixelSize,
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: FlatButton(
              shape: intrinsic && !isExotic
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4 * widget.pixelSize),
                      side: borderSide)
                  : CircleBorder(side: borderSide),
              padding: EdgeInsets.all(intrinsic ? 0 : 8 * widget.pixelSize),
              color: bgColor,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                print("$socketIndex $plugItemHash");
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  buildContent(BuildContext context) {
    Iterable<Widget> items = [
      buildDescription(context),
      buildSandBoxPerks(context),
      ScreenShotSocketItemStatsWidget(
        plugDefinition: definition,
        definition: itemDefinition,
        item: item,
        pixelSize: widget.pixelSize,
        socketController: widget.controller,
      ),
    ];
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.toList());
  }

  buildDescription(BuildContext context) {
    if ((definition?.displayProperties?.description?.length ?? 0) == 0)
      return Container();
    return Text(definition?.displayProperties?.description,
        style: TextStyle(
            fontSize: 24 * widget.pixelSize, fontWeight: FontWeight.w300));
  }

  buildSandBoxPerks(BuildContext context) {
    if (_sandboxPerkDefinitions == null) return Container();
    var perks = definition?.perks?.where((p) {
      if (p.perkVisibility != ItemPerkVisibility.Visible) return false;
      var def = _sandboxPerkDefinitions[p.perkHash];
      if ((def?.isDisplayable ?? false) == false) return false;
      return true;
    });
    if ((perks?.length ?? 0) == 0) return Container();
    return Column(
      children: perks
          ?.map((p) => Container(
              padding: EdgeInsets.only(
                top: 16 * widget.pixelSize,
              ),
              child: Row(
                key: Key("mod_perk_${p.perkHash}"),
                children: <Widget>[
                  Container(
                    height: 64 * widget.pixelSize,
                    width: 64 * widget.pixelSize,
                    child: ManifestImageWidget<DestinySandboxPerkDefinition>(
                        p.perkHash),
                  ),
                  Container(
                    width: 16 * widget.pixelSize,
                  ),
                  Expanded(
                      child: ManifestText<DestinySandboxPerkDefinition>(
                    p.perkHash,
                    style: TextStyle(
                        fontSize: 22 * widget.pixelSize,
                        fontWeight: FontWeight.w300),
                    textExtractor: (def) => def.displayProperties?.description,
                  )),
                ],
              )))
          ?.toList(),
    );
  }
}
