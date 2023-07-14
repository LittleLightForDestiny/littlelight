import 'package:flutter/material.dart';
import 'package:little_light/modules/vendors/pages/home/vendors_home.bloc.dart';
import 'package:little_light/modules/vendors/pages/home/vendors_home.view.dart';
import 'package:provider/provider.dart';

class VendorsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VendorsHomeBloc(context)),
      ],
      builder: (context, _) => VendorsHomeView(
        context.read<VendorsHomeBloc>(),
        context.watch<VendorsHomeBloc>(),
      ),
    );
  }
}
