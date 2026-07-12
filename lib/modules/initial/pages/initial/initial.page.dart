import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/offline_mode/offline_mode.bloc.dart';
import 'package:little_light/modules/initial/pages/initial/initial.view.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/storage/global_storage.service.dart';
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
              auth: context.read<AuthService>(),
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
              auth: context.read<AuthService>(),
              offlineModeBloc: context.read<OfflineModeBloc>(),
              manifest: context.read<ManifestService>(),
              littleLightData: context.read<LittleLightDataBloc>(),
              wishlistsService: context.read<WishlistsService>(),
              analytics: context.read<AnalyticsService>(),
              globalStorage: context.read<GlobalStorage>(),
            ),
          ),
        ],
        child: const InitialView(),
      ),
    );
  }
}
