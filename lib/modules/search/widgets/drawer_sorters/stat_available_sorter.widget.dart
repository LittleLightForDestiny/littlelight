import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/modules/search/blocs/search_sorter.bloc.dart';
import 'package:little_light/modules/search/widgets/drawer_sorters/available_sorter.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/sorters/items/export.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class StatAvailableSorterWidget extends AvailableSorterWidget with ManifestConsumer {
  const StatAvailableSorterWidget(
    ItemSortParameter parameter, {
    Key? key,
  }) : super(parameter, key: key);

  @override
  void onTap(BuildContext context) async {
    final items = context.read<SearchSorterBloc>().unsortedItems;
    if (items == null) return;
    final statHashes = <int>{};
    for (final item in items) {
      final statKeys = item.stats?.keys.map((e) => int.tryParse(e)).whereType<int>();
      if (statKeys == null) continue;
      statHashes.addAll(statKeys);
    }
    final statHash = await StatSelectionBottomSheet.show(context, statHashes);
    if (statHash == null) return;
    final param = ItemSortParameter(
      type: ItemSortParameterType.Stat,
      customData: {'statHash': statHash},
      direction: SorterDirection.Descending,
    );
    context.read<SearchSorterBloc>().addSorter(param);
  }
}

class StatSelectionBottomSheet extends StatelessWidget with ManifestConsumer {
  final Set<int> statHashes;
  const StatSelectionBottomSheet({Key? key, required this.statHashes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final future = manifest.getDefinitions<DestinyStatDefinition>(statHashes);
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(
          padding: EdgeInsets.all(8),
          child: HeaderWidget(child: Text("Select a stat".translate(context).toUpperCase()))),
      Flexible(
          child: FutureBuilder<Map<int, DestinyStatDefinition>>(
        future: future,
        builder: (context, snapshot) {
          final values = snapshot.data?.values;
          if (values == null) return Container();
          final ordered = values
              .sorted((a, b) => (a.index ?? 0).compareTo(b.index ?? 0)) //
              .map((d) => d.hash)
              .whereType<int>();
          return buildAttributeList(context, ordered.toList());
        },
      )),
    ]);
  }

  Widget buildAttributeList(BuildContext context, List<int> hashes) {
    final mq = MediaQuery.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(8) + EdgeInsets.only(bottom: mq.viewPadding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: statHashes.map((hash) => buildAttributeButton(context, hash)).toList(),
      ),
    );
  }

  Widget buildAttributeButton(BuildContext context, int hash) {
    return Container(
      margin: EdgeInsets.all(4),
      child: Material(
        borderRadius: BorderRadius.circular(4),
        color: context.theme.surfaceLayers.layer3,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.all(8),
            child: ManifestText<DestinyStatDefinition>(
              hash,
              style: context.textTheme.button,
              textAlign: TextAlign.center,
              uppercase: true,
            ),
          ),
          onTap: () => Navigator.of(context).pop(hash),
        ),
      ),
    );
  }

  static Future<int?> show(BuildContext context, Set<int> statHashes) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => StatSelectionBottomSheet(statHashes: statHashes),
    );
  }
}
