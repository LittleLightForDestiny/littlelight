import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/vendors/pages/home/vendor_data.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class VendorsReorderingListItemWidget extends StatelessWidget {
  final VendorData data;
  final int index;

  const VendorsReorderingListItemWidget(this.data, this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.surfaceLayers.layer0,
      child: Stack(children: [
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: buildBackground(context),
        ),
        Container(
          decoration:
              BoxDecoration(border: Border.all(color: LittleLightTheme.of(context).surfaceLayers.layer3, width: 1)),
          child: buildHeader(context),
        ),
      ]),
    );
  }

  Widget buildBackground(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    final url = definition?.locations?.first.backgroundImagePath ?? definition?.displayProperties?.largeIcon;
    return Stack(fit: StackFit.passthrough, children: [
      QueuedNetworkImage(
        fit: BoxFit.fitHeight,
        alignment: Alignment.topRight,
        imageUrl: BungieApiService.url(url),
      ),
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                context.theme.surfaceLayers.layer0,
                context.theme.surfaceLayers.layer0.withOpacity(.2),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.center,
            ),
          ),
        ),
      )
    ]);
  }

  Widget buildHeader(BuildContext context) {
    final definition = context.definition<DestinyVendorDefinition>(data.vendor.vendorHash);
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: EdgeInsets.all(8),
              color: context.theme.surfaceLayers.layer0,
              child: Icon(FontAwesomeIcons.bars),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 4),
            width: 36,
            height: 36,
            child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(definition?.displayProperties?.smallTransparentIcon),
            ),
          ),
          Container(
            width: 4,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    definition?.displayProperties?.name?.toUpperCase() ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(height: 2),
                  ManifestText<DestinyFactionDefinition>(definition?.factionHash,
                      style: const TextStyle(fontWeight: FontWeight.w300)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
