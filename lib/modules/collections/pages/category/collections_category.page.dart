import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.bloc.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.view.dart';
import 'package:provider/provider.dart';

class CollectionsCategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;

  CollectionsCategoryPage(this.categoryPresentationNodeHash);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CollectionsCategoryBloc(context, categoryPresentationNodeHash)),
      ],
      builder: (context, _) => CollectionsCategoryView(
        context.read<CollectionsCategoryBloc>(),
        context.watch<CollectionsCategoryBloc>(),
      ),
    );
  }
}
