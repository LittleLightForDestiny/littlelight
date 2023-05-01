import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/modules/triumphs/pages/record_details/record_details.bloc.dart';
import 'package:provider/provider.dart';

import 'record_details.view.dart';

class RecordDetailsPage extends StatelessWidget {
  final int itemHash;

  const RecordDetailsPage(this.itemHash, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RecordDetailsBloc>(create: (context) => RecordDetailsBloc(context, itemHash)),
      ],
      builder: (context, _) => RecordDetailsView(
        context.read<RecordDetailsBloc>(),
        context.watch<RecordDetailsBloc>(),
        context.watch<SelectionBloc>(),
      ),
    );
  }
}
