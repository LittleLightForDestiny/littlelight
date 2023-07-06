import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';
import 'collections_subcategory.bloc.dart';
import 'collections_subcategory.view.dart';

class CollectionsSubcategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;
  final List<int>? parentNodeHashes;

  CollectionsSubcategoryPage(this.categoryPresentationNodeHash, {this.parentNodeHashes});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectionsBloc>(
            create: (context) => CollectionsSubcategoryBloc(
                  context,
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                )),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<CollectionsBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onCollectibleTap(item),
            onHold: (item) => bloc.onCollectibleHold(item),
          );
        }),
      ],
      builder: (context, _) => CollectionsSubcategoryView(
        context.read<CollectionsBloc>(),
        context.watch<CollectionsBloc>(),
      ),
    );
  }
}
