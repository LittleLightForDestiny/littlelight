import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.bloc.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.view.dart';
import 'package:little_light/modules/collections/pages/subcategory/collections_subcategory.bloc.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';

class CollectionsCategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;
  final List<int>? parentNodeHashes;

  CollectionsCategoryPage(this.categoryPresentationNodeHash, {this.parentNodeHashes});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectionsBloc>(
            create: (context) => CollectionsCategoryBloc(
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
      builder: (context, _) => CollectionsCategoryView(
        context.read<CollectionsBloc>(),
        context.watch<CollectionsBloc>(),
      ),
    );
  }
}
