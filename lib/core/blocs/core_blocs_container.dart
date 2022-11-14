import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/notifications/notifications.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:provider/provider.dart';

import 'profile/profile.bloc.dart';

class CoreBlocsContainer extends StatelessWidget {
  final Widget child;
  CoreBlocsContainer(this.child);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserSettingsBloc>(create: (context) => getInjectedUserSettings()),
        ChangeNotifierProvider<LanguageBloc>(create: (context) => getInjectedLanguageService()),
        ChangeNotifierProvider<ProfileBloc>(create: (context) => getInjectedProfileService()),
        ChangeNotifierProvider<NotificationsBloc>(create: (context) => NotificationsBloc()),
        ChangeNotifierProvider<InventoryBloc>(create: (context) => InventoryBloc(context)),
        ChangeNotifierProvider<LoadoutsBloc>(create: (context) => LoadoutsBloc()),
      ],
      builder: (context, _) => child,
    );
  }
}
