import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/modules/initial/pages/initial/initial.view.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

import '../../blocs/manifest_downloader.bloc.dart';
import '../../blocs/select_membership.bloc.dart';
import '../../blocs/select_wishlists.bloc.dart';
import 'initial.bloc.dart';

class InitialPageContainer extends StatelessWidget {
  const InitialPageContainer() : super();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, result) => false,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<ManifestDownloaderBloc>(
            create: (context) => ManifestDownloaderBloc(
              manifest: context.read<ManifestService>(),
            ),
          ),
          ChangeNotifierProvider<SelectMembershipBloc>(
            create: (context) => SelectMembershipBloc(
              auth: GetIt.I<AuthService>(),
            ),
          ),
          ChangeNotifierProvider<SelectWishlistBloc>(
            create: (context) => SelectWishlistBloc(
              littleLightData: context.read<LittleLightDataBloc>(),
              wishlistsService: context.read<WishlistsService>(),
            ),
          ),
          ChangeNotifierProvider<InitialPageStateNotifier>(
            create: (context) => InitialPageStateNotifier(
              context,
            ),
          ),
        ],
        child: const InitialView(),
      ),
    );
  }
}
