import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

import 'collectibles_search.bloc.dart';
import 'collectibles_search.view.dart';

class CollectiblesSearchPage extends StatelessWidget {
  final int rootNode;

  CollectiblesSearchPage(this.rootNode);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectiblesSearchBloc>(
            create: (context) => CollectiblesSearchBloc(
                  context,
                  rootNode,
                )),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<CollectiblesSearchBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onCollectibleTap(item),
            onHold: (item) => bloc.onCollectibleHold(item),
          );
        }),
      ],
      builder: (context, _) => CollectiblesSearchView(
        context.read<CollectiblesSearchBloc>(),
        context.watch<CollectiblesSearchBloc>(),
      ),
    );
  }
}
