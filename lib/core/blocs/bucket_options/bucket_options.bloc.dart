import 'package:flutter/material.dart';
import 'package:little_light/core/repositories/user_settings/user_settings.repository.dart';
import 'package:little_light/models/bucket_display_options.dart';
import 'package:provider/provider.dart';

class BucketOptionsBloc extends ChangeNotifier {
  final UserSettingsRepository _userSettings;
  BucketOptionsBloc(BuildContext context)
      : _userSettings = context.read<UserSettingsRepository>();

  BucketDisplayType getDisplayTypeForCharacterBucket(int bucketHash) {
    final id = "$bucketHash";
    final stored = _userSettings.getDisplayOptionsForBucket(id)?.type;
    if (stored != null) return stored;
    final defaultType = defaultBucketDisplayOptions[id]?.type;
    if (defaultType != null) {
      return defaultType;
    }
    return BucketDisplayType.Medium;
  }

  void setDisplayTypeForCharacterBucket(
      int bucketHash, BucketDisplayType type) {
    final id = "$bucketHash";
    _userSettings.setDisplayOptionsForBucket(
        id, BucketDisplayOptions(type: type));
    notifyListeners();
  }

  BucketDisplayType getDisplayTypeForVaultBucket(int bucketHash) {
    final id = "vault_$bucketHash";
    final stored = _userSettings.getDisplayOptionsForBucket(id)?.type;
    if (stored != null) return stored;
    final defaultType = defaultBucketDisplayOptions[id]?.type;
    if (defaultType != null) {
      return defaultType;
    }
    return BucketDisplayType.Small;
  }

  void setDisplayTypeForVaultBucket(int bucketHash, BucketDisplayType type) {
    final id = "vault_$bucketHash";
    _userSettings.setDisplayOptionsForBucket(
        id, BucketDisplayOptions(type: type));
    notifyListeners();
  }
}
