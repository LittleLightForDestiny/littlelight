import 'dart:convert';
import 'dart:io';

import 'package:little_light/services/storage/migrations/storage_migrations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationV1x9x0 extends StorageMigration {
  @override
  String get version => '1.9.0';

  @override
  Future<void> migrate() async {
    final _prefs = await SharedPreferences.getInstance();
    final _prefKeys = _prefs.getKeys();
    final _storageRoot = await getFileRoot();
    final _dbRoot = await getDatabaseRoot();

    _prefs.remove("/currentVersion");
    _prefs.remove("/versionUpdatedDate");

    removeLegacyCurrentVersion(_prefs, _prefKeys);
    removeLittleLightAPICredentials(_prefs, _prefKeys);

    replacePref('/latest_screen', 'latestScreen', _prefs);
    replacePref('/userpref_autoOpenKeyboard', 'autoOpenKeyboard', _prefs);
    replacePref('selected_account_id', 'currentAccountID', _prefs);
    replacePref('selected_language', 'currentLanguageCode', _prefs);
    replacePref('selected_membership_id', 'currentMembershipID', _prefs);
    replacePref('/userpref_defaultFreeSlots', 'defaultFreeSlots', _prefs);
    replacePref('/userpref_hasTappedGhost', 'hasTappedGhost', _prefs);
    replacePref('/userpref_keepAwake', 'keepAwake', _prefs);
    replacePref('/tapToSelect', 'tapToSelect', _prefs);

    await migrateAccountIDs(_prefs, _storageRoot);

    await moveFileOnSubdir("$_storageRoot/accounts", "memberships.json", "membershipData.json");

    await moveFileOnSubdir("$_storageRoot/memberships", "tracked_objectives.json", "trackedObjectives.json");
    await moveFileOnSubdir("$_storageRoot/memberships", "userpref_characterOrdering.json", "characterOrdering.json");

    await moveFile("$_storageRoot/userpref_itemOrdering.json", "$_storageRoot/itemOrdering.json");
    await moveFile("$_storageRoot/userpref_pursuitOrdering.json", "$_storageRoot/pursuitOrdering.json");

    await tryDelete("$_storageRoot/bungie_common_settings.json");
    await tryDelete("$_storageRoot/parsedWishlists.json");
    await tryDelete("$_storageRoot/wishlists.json");
    await tryDelete("$_storageRoot/priorityTags.json");
    await tryDelete("$_storageRoot/rawData", true);
    await tryDelete("$_storageRoot/rawWishlists", true);
    await tryDelete("$_storageRoot/languages", true);

    await tryDelete("$_dbRoot/languages", true);
  }

  removeLegacyCurrentVersion(SharedPreferences prefs, Iterable<String> prefKeys) {
    try {
      final manifestVersionKeys = prefKeys.where((k) {
        final regexp = RegExp("languages/.*?/manifestVersion");
        return regexp.hasMatch(k);
      });
      for (final key in manifestVersionKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }
  }

  void removeLittleLightAPICredentials(SharedPreferences prefs, Iterable<String> prefKeys) {
    try {
      final membershipSecretKeys = prefKeys.where((k) {
        final regexp = RegExp("memberships/.*?/membership_secret");
        return regexp.hasMatch(k);
      });
      for (final key in membershipSecretKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }

    /// remove membership files `membership_uuid`
    try {
      final membershipUUIDKeys = prefKeys.where((k) {
        final regexp = RegExp("memberships/.*?/membership_u_u_i_d");
        return regexp.hasMatch(k);
      });
      for (final key in membershipUUIDKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> migrateAccountIDs(SharedPreferences prefs, String? storageRoot) async {
    try {
      final accountIDs = prefs.getStringList('account_ids');
      if (accountIDs != null) {
        await File("$storageRoot/accountIDs.json").writeAsString(jsonEncode(accountIDs));
      }
    } catch (e) {
      print(e);
    }
  }
}
