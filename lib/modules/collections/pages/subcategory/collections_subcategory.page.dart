import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';

import 'package:provider/provider.dart';

import 'collections_subcategory.bloc.dart';
import 'collections_subcategory.view.dart';

class CollectionsSubcategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;

  CollectionsSubcategoryPage(this.categoryPresentationNodeHash);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CollectionsSubcategoryBloc(context, categoryPresentationNodeHash)),
        Provider<ItemInteractionHandlerBloc>(create: (context) {
          final bloc = context.read<CollectionsSubcategoryBloc>();
          return ItemInteractionHandlerBloc(
            onTap: (item) => bloc.onItemTap(item),
            onHold: (item) => bloc.onItemHold(item),
          );
        }),
      ],
      builder: (context, _) => CollectionsSubcategoryView(
        context.read<CollectionsSubcategoryBloc>(),
        context.watch<CollectionsSubcategoryBloc>(),
      ),
    );
  }
}
