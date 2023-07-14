import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';
import 'package:little_light/modules/triumphs/pages/category/triumphs_category.bloc.dart';
import 'package:little_light/modules/triumphs/pages/category/triumphs_category.view.dart';
import 'package:provider/provider.dart';

class TriumphsCategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;
  final List<int>? parentNodeHashes;

  TriumphsCategoryPage(this.categoryPresentationNodeHash, {this.parentNodeHashes});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TriumphsBloc>(
            create: (context) => TriumphsCategoryBloc(
                  context,
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                )),
      ],
      builder: (context, _) => TriumphsCategoryView(
        context.read<TriumphsBloc>(),
        context.watch<TriumphsBloc>(),
      ),
    );
  }
}
