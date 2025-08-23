import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:provider/provider.dart';

class DetailsItemRawDataWidget extends StatelessWidget {
  const DetailsItemRawDataWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: PersistentCollapsibleContainer(
        title: Text("Item data".translate(context).toUpperCase()),
        persistenceID: 'item data',
        content: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final bloc = context.read<ItemDetailsBloc>();
    return Container(
      padding: EdgeInsets.all(8),
      child: Table(
        columnWidths: {0: IntrinsicColumnWidth()},
        children: [
          TableRow(children: [
            Container(
              padding: const EdgeInsets.only(right: 8),
              child: Text("itemHash:")),
              SelectableText(bloc.itemHash.toString())]),
          if (bloc.item?.instanceId != null)
            TableRow(children: [
            Container(
              padding: const EdgeInsets.only(right: 8),
              child: Text("instanceId:")),
              SelectableText(bloc.item?.instanceId ?? "")]),
        ],
      ),
    );
  }
}
