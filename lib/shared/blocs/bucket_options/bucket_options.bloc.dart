import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:provider/provider.dart';

class ItemSectionOptionsBloc extends ChangeNotifier {
  final UserSettingsBloc _userSettings;
  ItemSectionOptionsBloc(BuildContext context) : _userSettings = context.read<UserSettingsBloc>();

  BucketDisplayType getDisplayTypeForItemSection(String id,
      {BucketDisplayType defaultValue = BucketDisplayType.Medium}) {
    final stored = _userSettings.getDisplayOptionsForItemSection(id)?.type;
    if (stored != null) return stored;
    return defaultValue;
  }

  void setDisplayTypeForItemSection(String id, BucketDisplayType type) {
    _userSettings.setDisplayOptionsForItemSection(id, BucketDisplayOptions(type: type));
    notifyListeners();
  }
}
