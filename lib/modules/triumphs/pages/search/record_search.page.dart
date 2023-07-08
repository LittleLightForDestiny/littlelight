import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:provider/provider.dart';
import 'record_search.bloc.dart';
import 'record_search.view.dart';

class RecordsSearchPage extends StatelessWidget {
  final int rootNode;

  RecordsSearchPage(this.rootNode);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordsSearchBloc>(
            create: (context) => RecordsSearchBloc(
                  context,
                  rootNode,
                )),
      ],
      builder: (context, _) => RecordsSearchView(
        context.read<RecordsSearchBloc>(),
        context.watch<RecordsSearchBloc>(),
      ),
    );
  }
}
