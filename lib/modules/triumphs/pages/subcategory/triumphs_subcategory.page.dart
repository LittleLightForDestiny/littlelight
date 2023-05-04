import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/blocs/base_triumphs.bloc.dart';

import 'package:provider/provider.dart';

import 'triumphs_subcategory.bloc.dart';
import 'triumphs_subcategory.view.dart';

class TriumphsSubcategoryPage extends StatelessWidget {
  final int categoryPresentationNodeHash;
  final List<int>? parentNodeHashes;

  TriumphsSubcategoryPage(this.categoryPresentationNodeHash, {this.parentNodeHashes});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TriumphsBloc>(
            create: (context) => TriumphsSubcategoryBloc(
                  context,
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                )),
      ],
      builder: (context, _) => TriumphsSubcategoryView(
        context.read<TriumphsBloc>(),
        context.watch<TriumphsBloc>(),
      ),
    );
  }
}
