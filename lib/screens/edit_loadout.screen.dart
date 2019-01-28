import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/select_loadout_background.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_slot.widget.dart';
import 'package:uuid/uuid.dart';

class EditLoadoutScreen extends StatefulWidget {
  final Loadout loadout;
  EditLoadoutScreen({Key key, this.loadout}) : super(key: key);

  final List<int> bucketOrder = [
    InventoryBucket.subclass,
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor,
    InventoryBucket.ghost,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
  ];

  @override
  EditLoadoutScreenState createState() => new EditLoadoutScreenState();
}

class EditLoadoutScreenState extends State<EditLoadoutScreen> {
  LoadoutItemIndex _itemIndex;
  DestinyInventoryItemDefinition emblemDefinition;
  Loadout _loadout;
  String _nameInputLabel = "";
  @override
  initState() {
    if (widget.loadout != null) {
      _loadout = Loadout.fromMap(widget.loadout.toMap());
    } else {
      String uuid = Uuid().v4();
      _loadout = Loadout(uuid, "", null, [], []);
    }
    super.initState();
    fetchTranslations();
    loadEmblemDefinition();
    buildItemIndex();
  }

  fetchTranslations() async {
    TranslateService translate = new TranslateService();
    _nameInputLabel = await translate.getTranslation("Loadout Name");
    setState(() {});
  }

  loadEmblemDefinition() async {
    ManifestService manifest = new ManifestService();
    emblemDefinition = await manifest
        .getDefinition<DestinyInventoryItemDefinition>(_loadout.emblemHash);
    setState(() {});
  }

  buildItemIndex() async {
    ManifestService manifest = new ManifestService();
    await manifest.getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketOrder);
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(_loadout,
        onlyEquipped: false);
    if (mounted) {
      setState(() {});
    }
  }

  Color get emblemColor {
    if (emblemDefinition == null) return Colors.grey.shade900;
    Color color = Color.fromRGBO(
        emblemDefinition.backgroundColor.red,
        emblemDefinition.backgroundColor.green,
        emblemDefinition.backgroundColor.blue,
        1.0);
    return Color.lerp(color, Colors.grey.shade900, .5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: emblemColor,
        appBar: AppBar(
            title: TranslatedTextWidget("Edit Loadout"),
            flexibleSpace: buildAppBarBackground(context)),
        body: ListView.builder(
          itemCount: _itemIndex == null ? 2 : widget.bucketOrder.length + 2,
          padding: EdgeInsets.all(8), itemBuilder: itemBuilder
        ));
  }

  Widget itemBuilder(BuildContext context, int index) {
    switch (index) {
      case 0:
        return buildNameTextField(context);
      case 1:
        return buildSelectBackgroundButton(context);
    }
    if(widget.bucketOrder[index - 2] != null){
      return LoadoutSlotWidget(bucketHash: widget.bucketOrder[index - 2]);
    }
    return Container();
  }

  Widget buildNameTextField(BuildContext context) {
    return Container(
      padding:EdgeInsets.all(8),
      child:TextFormField(
      initialValue: _loadout.name,
      decoration: InputDecoration(labelText: _nameInputLabel),
    ));
  }

  Widget buildSelectBackgroundButton(BuildContext context) {
    return Container(
      padding:EdgeInsets.all(8), child:RaisedButton(
      child: TranslatedTextWidget("Select Loadout Background"),
      onPressed: () async {
        var emblemHash = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectLoadoutBackgroundScreen(),
          ),
        );
        if (emblemHash != null) {
          _loadout.emblemHash = emblemHash;
          loadEmblemDefinition();
        }
      },
    ));
  }

  buildAppBarBackground(BuildContext context) {
    if(emblemDefinition == null) return Container();
        return Container(
            constraints: BoxConstraints.expand(),
            child: CachedNetworkImage(
                imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
                fit: BoxFit.cover,
                alignment: Alignment(-.8, 0)));
  }
}
