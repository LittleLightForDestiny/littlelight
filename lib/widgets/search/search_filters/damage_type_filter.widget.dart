import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/models/destiny_damage_type_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/item_filters/damage_type_filter.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class DamageTypeFilterWidget extends BaseSearchFilterWidget<DamageTypeFilter> {
  DamageTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _DamageTypeFilterWidgetState createState() => _DamageTypeFilterWidgetState();
}

class _DamageTypeFilterWidgetState extends BaseSearchFilterWidgetState<
    DamageTypeFilterWidget, DamageTypeFilter, DestinyDamageTypeDefinition> {
  Map<int, DestinyDamageTypeDefinition> _definitions;

  @override
  Iterable<DestinyDamageTypeDefinition> get options {
    if (_definitions == null) return List();
    var _options = filter.availableValues.map((h) => _definitions[h]).toList();
    _options.sort((a, b) => a?.index?.compareTo(b?.index ?? -1) ?? 0);
    return _options;
  }

  @override
  onUpdate() async {
    _definitions = await ManifestService()
        .getDefinitions<DestinyDamageTypeDefinition>(filter.availableValues);
    super.onUpdate();
  }

  @override
  Widget buildButtons(BuildContext context) {
    var textButtons = options
        .where((e) => e?.displayProperties?.hasIcon != true)
        .map((e) => buildButton(context, e))
        .toList();
    var iconButtons = options
        .where((e) => e?.displayProperties?.hasIcon == true)
        .map((e) => Expanded(child: buildButton(context, e)))
        .toList();
    return Column(
        children: [Column(children: textButtons), Row(children: iconButtons)]);
  }

  @override
  Widget buildButtonLabel(
      BuildContext context, DestinyDamageTypeDefinition value) {
    if (value?.displayProperties?.hasIcon == true) {
      return Container(
          margin: EdgeInsets.all(8),
          width: 32,
          height: 32,
          child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(value?.displayProperties?.icon)));
    }
    var name = value?.displayProperties?.name ?? value?.enumValue?.toString();
    if (name != null) {
      return Text(name.toUpperCase());
    }
    return TranslatedTextWidget("None", uppercase: true);
  }

  @override
  Color buttonBgColor(DestinyDamageTypeDefinition value) {
    return super.buttonBgColor(value);
  }

  @override
  valueToFilter(DestinyDamageTypeDefinition value) {
    return value?.hash;
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget("Damage Type", uppercase: true,);
  }

  @override
  Widget buildDisabledLabel(BuildContext context) {
    try{
      var value = options.single;
      print(value.enumValue);
      if(value.enumValue == DamageType.None){
        return Container();
      }
    }catch(_){
      return Container();
    }
    return super.buildDisabledLabel(context);
  }
}
