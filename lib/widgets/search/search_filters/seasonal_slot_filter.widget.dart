import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/item_filters/season_slot_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class SeasonalSlotFilterWidget
    extends BaseSearchFilterWidget<SeasonSlotFilter> {
  SeasonalSlotFilterWidget(SearchController controller) : super(controller);

  @override
  _SeasonalSlotFilterWidgetState createState() =>
      _SeasonalSlotFilterWidgetState();
}

class _SeasonalSlotFilterWidgetState extends BaseSearchFilterWidgetState<
    SeasonalSlotFilterWidget,
    SeasonSlotFilter,
    DestinyInventoryItemDefinition> with LittleLightDataConsumer{
  Map<int, DestinyInventoryItemDefinition> _definitions;
  List<int> seasonalSlots;

  @override
  Iterable<DestinyInventoryItemDefinition> get options {
    if (_definitions == null) return [];
    var _options = filter.availableValues.map((h) => _definitions[h]).toList();
    if (seasonalSlots != null) {
      _options.sort((a, b) =>
          seasonalSlots
              .indexOf(a?.hash)
              ?.compareTo(seasonalSlots.indexOf(b?.hash) ?? -1) ??
          0);
    }

    return _options;
  }

  @override
  onUpdate() async {
    var gameData = await littleLightData.getGameData();
    seasonalSlots = gameData.seasonalModSlots;
    _definitions = await ManifestService()
        .getDefinitions<DestinyInventoryItemDefinition>(filter.availableValues);
    super.onUpdate();
  }

  @override
  Widget buildButtons(BuildContext context) {
    var buttons = options.map((e) => buildButton(context, e)).toList();
    return Column(children: [Column(children: buttons)]);
  }

  @override
  Widget buildButtonLabel(
      BuildContext context, DestinyInventoryItemDefinition value) {
    var name = value?.itemTypeDisplayName;
    if (name != null) {
      return Text(name.toUpperCase());
    }
    return TranslatedTextWidget("None", uppercase: true);
  }

  @override
  Color buttonBgColor(DestinyInventoryItemDefinition value) {
    return super.buttonBgColor(value);
  }

  @override
  valueToFilter(DestinyInventoryItemDefinition value) {
    return value?.hash ?? -1;
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Season Slot",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    if (options.length <= 1) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
