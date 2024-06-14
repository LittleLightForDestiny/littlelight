import 'package:little_light/core/blocs/app/app.bloc.dart';
import 'package:little_light/core/blocs/clarity/clarity_data.bloc.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/core/blocs/objective_tracking/objective_tracking.bloc.dart';
import 'package:little_light/core/blocs/profile/craftables_helper.bloc.dart';
import 'package:little_light/core/blocs/storage/account/account_storage.bloc.dart';
import 'package:little_light/core/blocs/storage/global/global_storage.bloc.dart';
import 'package:little_light/core/blocs/storage/language/language_storage.bloc.dart';
import 'package:little_light/core/blocs/storage/membership/membership_storage.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendors.bloc.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:provider/provider.dart';

import 'app_lifecycle/app_lifecycle.bloc.dart';
import 'inventory/inventory.bloc.dart';
import 'language/language.bloc.dart';
import 'language/language.consumer.dart';
import 'notifications/notifications.bloc.dart';
import 'offline_mode/offline_mode.bloc.dart';
import 'profile/profile.bloc.dart';
import 'selection/selection.bloc.dart';
import 'user_settings/user_settings.bloc.dart';

class CoreBlocsContainer extends MultiProvider {
  CoreBlocsContainer()
      : super(
          providers: [
            Provider(create: (c) => AppBloc(c)),
            Provider(create: (c) => GlobalStorageBloc(c)),
            Provider(create: (c) => LanguageStorageBloc()),
            Provider(create: (c) => AccountStorageBloc()),
            Provider(create: (c) => MembershipStorageBloc()),
            Provider(create: (c) => getInjectedAuthService()),
            Provider(create: (c) => getInjectedBungieApi()),
            Provider(create: (c) => getInjectedDestinySettingsService()),
            ChangeNotifierProvider(create: (context) => UserSettingsBloc(context)),
            ChangeNotifierProvider(create: (context) => AppLifecycleBloc()),
            ChangeNotifierProvider(create: (context) => OfflineModeBloc()),
            ChangeNotifierProvider<ManifestService>(
              create: (context) => getInjectedManifestService().initContext(context),
            ),
            ChangeNotifierProvider<LanguageBloc>(create: (context) => getInjectedLanguageService()),
            ChangeNotifierProvider(create: (context) => ItemNotesBloc(context)),
            ChangeNotifierProvider(create: (context) => LittleLightDataBloc(context)),
            ChangeNotifierProvider<ProfileBloc>(create: (context) => ProfileBloc(context)),
            ChangeNotifierProvider<WishlistsService>(create: (context) => getInjectedWishlistsService()),
            ChangeNotifierProvider<NotificationsBloc>(create: (context) => NotificationsBloc()),
            ChangeNotifierProvider<InventoryBloc>(create: (context) => InventoryBloc(context)),
            ChangeNotifierProvider<VendorsBloc>(create: (context) => VendorsBloc(context)),
            ChangeNotifierProvider<LoadoutsBloc>(create: (context) => LoadoutsBloc(context)),
            ChangeNotifierProvider<SelectionBloc>(create: (context) => SelectionBloc(context)),
            ChangeNotifierProvider<ItemSectionOptionsBloc>(create: (context) => ItemSectionOptionsBloc(context)),
            ChangeNotifierProvider<ObjectiveTrackingBloc>(create: (context) => ObjectiveTrackingBloc(context)),
            ChangeNotifierProvider<ClarityDataBloc>(create: (context) => ClarityDataBloc(context)),
            ChangeNotifierProvider<CraftablesHelperBloc>(create: (context) => CraftablesHelperBloc(context)),
          ],
        );
}
