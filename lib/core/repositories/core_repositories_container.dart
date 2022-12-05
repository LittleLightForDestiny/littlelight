import 'package:little_light/core/repositories/user_settings/user_settings.repository.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:provider/provider.dart';

class CoreRepositoriesContainer extends MultiProvider {
  CoreRepositoriesContainer()
      : super(
          providers: [
            Provider<UserSettingsRepository>(create: (context) => getInjectedUserSettings()),
          ],
        );
}
