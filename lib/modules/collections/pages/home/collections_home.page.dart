import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/blocs/base_collections.bloc.dart';
import 'package:provider/provider.dart';
import 'collections_home.bloc.dart';
import 'collections_home.view.dart';

class CollectionsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CollectionsBloc>(create: (context) => CollectionsHomeBloc(context)),
      ],
      builder: (context, _) => CollectionsHomeView(
        context.read<CollectionsBloc>(),
        context.watch<CollectionsBloc>(),
      ),
    );
  }
}
