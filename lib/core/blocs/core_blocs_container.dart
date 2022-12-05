import 'package:little_light/core/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/profile/profile_helpers.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:provider/provider.dart';

import 'profile/profile.bloc.dart';

class CoreBlocsContainer extends MultiProvider {
  CoreBlocsContainer()
      : super(
          providers: [
            ChangeNotifierProvider<LanguageBloc>(create: (context) => getInjectedLanguageService()),
            ChangeNotifierProvider<ProfileBloc>(create: (context) => getInjectedProfileService()),
            ChangeNotifierProvider<ProfileHelpersBloc>(create: (context) => ProfileHelpersBloc(context)),
            ChangeNotifierProvider<NotificationsBloc>(create: (context) => NotificationsBloc()),
            ChangeNotifierProvider<InventoryBloc>(create: (context) => InventoryBloc(context)),
            ChangeNotifierProvider<BucketOptionsBloc>(create: (context) => BucketOptionsBloc(context)),
            ChangeNotifierProvider<LoadoutsBloc>(create: (context) => LoadoutsBloc()),
          ],
        );
}
