// @dart=2.9

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/pages/item_search/search.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/item_filters/avoid_instance_ids_filter.dart';
import 'package:little_light/utils/item_filters/class_type_filter.dart';
import 'package:little_light/utils/item_filters/item_bucket_filter.dart';
import 'package:little_light/utils/item_filters/text_filter.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/quick_transfer_list.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/text_search_filter.widget.dart';

class SelectLoadoutItemView extends SearchScreen {
  final Iterable<String> idsToAvoid;
  final DestinyClass classType;

  final int bucketHash;

  final int emblemHash;

  SelectLoadoutItemView({this.bucketHash, this.emblemHash, this.classType, this.idsToAvoid})
      : super(
            controller: SearchController.withDefaultFilters(firstRunFilters: [
          ItemBucketFilter(selected: {bucketHash}, enabled: true),
          ClassTypeFilter(selected: [classType].toSet(), enabled: true),
          AvoidInstanceIdsFilter(selected: idsToAvoid.toSet(), enabled: true)
        ], filters: [
          TextFilter(enabled: false),
        ]));

  @override
  SelectLoadoutItemScreenState createState() => SelectLoadoutItemScreenState();
}

class SelectLoadoutItemScreenState extends SearchScreenState<SelectLoadoutItemView> with ManifestConsumer {
  DestinyInventoryItemDefinition emblemDefinition;
  DestinyInventoryBucketDefinition bucketDefinition;

  initState() {
    super.initState();
    loadDefs();
  }

  loadDefs() async {
    bucketDefinition = await manifest.getDefinition<DestinyInventoryBucketDefinition>(widget.bucketHash);
    if (widget.emblemHash != null) {
      emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(widget.emblemHash);
    }
    setState(() {});
  }

  TextFilter get textFilter {
    return [controller.preFilters, controller.filters, controller.postFilters]
        .expand((element) => element)
        .firstWhere((element) => element is TextFilter, orElse: () => null);
  }

  @override
  buildAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: buildAppBarBackground(context),
      title: buildAppBarTitle(context),
      elevation: 2,
      actions: <Widget>[
        IconButton(
          enableFeedback: false,
          icon: textFilter.enabled ? Icon(Icons.close) : Icon(Icons.search),
          onPressed: () {
            textFilter.enabled = !textFilter.enabled;
            controller.update();
            setState(() {});
          },
        ),
        Builder(
            builder: (context) => IconButton(
                  enableFeedback: false,
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ))
      ],
    );
  }

  buildAppBarTitle(BuildContext context) {
    if (textFilter.enabled) {
      return TextSearchFilterWidget(controller, forceAutoFocus: true);
    }
    return TranslatedTextWidget(
      "Select {bucketName}",
      overflow: TextOverflow.fade,
      replace: {'bucketName': bucketDefinition?.displayProperties?.name ?? ""},
    );
  }

  buildAppBarBackground(BuildContext context) {
    if (emblemDefinition == null) return Container();
    return Container(
        constraints: BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: Alignment(-.8, 0)));
  }

  @override
  buildList(BuildContext context) {
    return QuickTransferListWidget(controller: controller);
  }
}
