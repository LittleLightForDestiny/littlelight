import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:intl/intl.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/widgets/common/masterwork_counter/base_masterwork_counter.widget.dart';

class ScreenshotMasterworkCounterWidget extends BaseMasterworkCounterWidget {
  final double pixelSize;
  ScreenshotMasterworkCounterWidget(
      {DestinyItemComponent item, Key key, this.pixelSize = 1})
      : super(item: item, key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenshotMasterworkCounterState();
  }
}

class ScreenshotMasterworkCounterState extends BaseMasterworkCounterWidgetState<
    ScreenshotMasterworkCounterWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (this.masterworkObjective == null ||
        this.masterworkObjectiveDefinition?.displayProperties?.icon == null) {
      return Container();
    }
    return Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildIcon(context),
            Container(
              width: widget.pixelSize*4,
            ),
            buildProgressDescription(context),
            Container(
              width: widget.pixelSize*4,
            ),
            buildProgressValue(context),
            Container(
              width: widget.pixelSize*4,
            ),
            buildBigIcon(context)
          ],
        ));
  }

  Widget buildIcon(BuildContext context) {
    return Container(
      width: widget.pixelSize*24,
      height: widget.pixelSize*24,
      child: Image(
          image: AdvancedNetworkImage(BungieApiService.url(
              masterworkObjectiveDefinition.displayProperties.icon))),
    );
  }

  Widget buildProgressDescription(BuildContext context) {
    return Text(masterworkObjectiveDefinition.progressDescription,
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          color: Colors.white, fontSize: widget.pixelSize * 20));
  }

  Widget buildProgressValue(BuildContext context) {
    var formatter = NumberFormat.decimalPattern(StorageService.getLanguage());
    var formattedValue = formatter.format(masterworkObjective.progress);
    return Text("$formattedValue",
        style: TextStyle(
            color: Colors.amber.shade200, fontSize: widget.pixelSize * 20));
  }

  Widget buildBigIcon(BuildContext context) {
    return Container(
        width: widget.pixelSize * 60,
        height: widget.pixelSize * 100,
        child: Image.asset(
          'assets/imgs/masterwork-icon.png',
          fit: BoxFit.cover,
        ));
  }
}
