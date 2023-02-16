import 'package:flutter/src/widgets/framework.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.bloc.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.page_route.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.view.dart';
import 'package:provider/provider.dart';

class QuickTransferPage extends StatelessWidget {
  const QuickTransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = QuickTransferPageRouteArguments.of(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => QuickTransferBloc(
            context,
            bucketHash: args?.bucketHash,
            characterId: args?.characterId,
          ),
        ),
      ],
      builder: (context, _) => QuickTransferView(
        context.read<QuickTransferBloc>(),
        context.watch<QuickTransferBloc>(),
      ),
    );
  }
}
