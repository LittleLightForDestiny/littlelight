import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/shared/views/base_presentation_node.view.dart';

abstract class BaseTriumphsView extends BasePresentationNodeView {
  TriumphsBloc get bloc;

  const BaseTriumphsView({Key? key}) : super(key: key);

  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          final tab = DefaultTabController.of(context).index;
          final rootNodeHash = tabNodes?[tab].hash;
          if (rootNodeHash == null) return;
          bloc.openSearch(rootNodeHash);
        },
      )
    ];
  }
}
