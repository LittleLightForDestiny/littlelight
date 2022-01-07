import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/models/destiny_energy_type_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/item_filters/energy_type_filter.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class EnergyTypeFilterWidget extends BaseSearchFilterWidget<EnergyTypeFilter> {
  EnergyTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _EnergyTypeFilterWidgetState createState() => _EnergyTypeFilterWidgetState();
}

class _EnergyTypeFilterWidgetState
    extends BaseSearchFilterWidgetState<EnergyTypeFilterWidget, EnergyTypeFilter, DestinyEnergyTypeDefinition>
    with ManifestConsumer {
  Map<int, DestinyEnergyTypeDefinition> _definitions;

  @override
  Iterable<DestinyEnergyTypeDefinition> get options {
    if (_definitions == null) return [];
    var _options = filter.availableValues.map((h) => _definitions[h]).toList();
    _options.sort((a, b) => a?.index?.compareTo(b?.index ?? -1) ?? 0);
    return _options;
  }

  @override
  onUpdate() async {
    _definitions = await manifest.getDefinitions<DestinyEnergyTypeDefinition>(filter.availableValues);
    super.onUpdate();
  }

  @override
  Widget buildButtons(BuildContext context) {
    var textButtons =
        options.where((e) => e?.displayProperties?.hasIcon != true).map((e) => buildButton(context, e)).toList();
    var iconButtons = options
        .where((e) => e?.displayProperties?.hasIcon == true)
        .map((e) => Expanded(child: buildButton(context, e)))
        .toList();
    return Column(children: [Column(children: textButtons), Row(children: iconButtons)]);
  }

  @override
  Widget buildButtonLabel(BuildContext context, DestinyEnergyTypeDefinition value) {
    if (value?.displayProperties?.hasIcon == true) {
      return Container(
          margin: EdgeInsets.all(8),
          width: 32,
          height: 32,
          child: QueuedNetworkImage(imageUrl: BungieApiService.url(value?.displayProperties?.icon)));
    }
    var name = value?.displayProperties?.name ?? value?.enumValue?.toString();
    if (name != null) {
      return Text(name.toUpperCase());
    }
    return TranslatedTextWidget("None", uppercase: true);
  }

  @override
  Color buttonBgColor(DestinyEnergyTypeDefinition value) {
    return super.buttonBgColor(value);
  }

  @override
  valueToFilter(DestinyEnergyTypeDefinition value) {
    return value?.hash;
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Energy Type",
      uppercase: true,
    );
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    try {
      var value = options.single;
      if (value.enumValue == DestinyEnergyType.Any) {
        return Container();
      }
    } catch (_) {
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
