import 'package:flutter/material.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.bloc.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.view.dart';
import 'package:provider/provider.dart';

class VendorDetailsPage extends StatelessWidget {
  final String characterId;
  final int vendorHash;

  VendorDetailsPage(String this.characterId, this.vendorHash);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => VendorDetailsBloc(context, this.characterId, this.vendorHash)),
      ],
      builder: (context, _) => VendorDetailsView(
        context.read<VendorDetailsBloc>(),
        context.watch<VendorDetailsBloc>(),
      ),
    );
  }
}
