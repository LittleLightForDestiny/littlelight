import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/loadout_filter_options.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';
import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class LoadoutFilterWidget extends BaseDrawerFilterWidget<LoadoutFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Loadout".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, LoadoutFilterOptions data) {
    final loadouts = context.watch<LoadoutsBloc>().loadouts;
    final availableValues = data.availableValues;
    final values = data.value;
    final allLoadouts = loadouts ?? [];
    final availableLoadouts = allLoadouts.where((t) => availableValues.contains(t.assignedId));
    final hasNone = availableValues.contains(null);
    return Column(
      children: availableLoadouts.map(
            (loadout) {
              final emblemHash = loadout.emblemHash;
              return FilterButtonWidget(
                Text(
                  loadout.name.toUpperCase(),
                  style: TextStyle(shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                    ),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                    ),
                  ]),
                ),
                background: emblemHash == null
                    ? null
                    : ManifestImageWidget<DestinyInventoryItemDefinition>(
                        emblemHash,
                        urlExtractor: (def) => def.secondarySpecial,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                selected: values.contains(loadout.assignedId),
                onTap: () => updateOption(context, data, loadout.assignedId, false),
                onLongPress: () => updateOption(context, data, loadout.assignedId, true),
              );
            },
          ).toList() +
          [
            if (hasNone)
              FilterButtonWidget(
                Text(
                  "None".translate(context).toUpperCase(),
                ),
                selected: values.contains(null),
                onTap: () => updateOption(context, data, null, false),
                onLongPress: () => updateOption(context, data, null, true),
              ),
          ],
    );
  }

  Widget buildIcon(BuildContext context, DamageType type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          type.icon,
          color: type.getColorLayer(context).layer3,
        ));
  }
}
