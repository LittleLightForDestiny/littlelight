import 'dart:convert';
import 'dart:io';

import 'package:little_light/services/storage/migrations/storage_migrations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MigrationV1x7x90 extends StorageMigration {
  @override
  String get version => '1.7.90';

  @override
  Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final prefKeys = prefs.getKeys();
    final storageRoot = await getFileRoot();
    final dbRoot = await getDatabaseRoot();

    try {
      prefs.remove('currentVersion');
      final manifestVersionKeys = prefKeys.where((k) {
        final regexp = RegExp("languages\/.*?\/manifestVersion");
        return regexp.hasMatch(k);
      });
      for (final key in manifestVersionKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }

    try {
      final membershipSecretKeys = prefKeys.where((k) {
        final regexp = RegExp("memberships\/.*?\/membership_secret");
        return regexp.hasMatch(k);
      });
      for (final key in membershipSecretKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }

    try {
      final membershipUUIDKeys = prefKeys.where((k) {
        final regexp = RegExp("memberships\/.*?\/membership_u_u_i_d");
        return regexp.hasMatch(k);
      });
      for (final key in membershipUUIDKeys) {
        prefs.remove(key);
      }
    } catch (e) {
      print(e);
    }

    try {
      final latestScreen = prefs.getString('/latest_screen');
      if (latestScreen != null) {
        prefs.setString("latestScreen", latestScreen);
        prefs.remove('/latest_screen');
      }
    } catch (e) {
      print(e);
    }

    try {
      final autoOpenKeyboard = prefs.getBool('/userpref_autoOpenKeyboard');
      if (autoOpenKeyboard != null) {
        prefs.setBool("autoOpenKeyboard", autoOpenKeyboard);
        prefs.remove('/userpref_autoOpenKeyboard');
      }
    } catch (e) {
      print(e);
    }

    try {
      final currentAccountID = prefs.getString('selected_account_id');
      if (currentAccountID != null) {
        prefs.setString("currentAccountID", currentAccountID);
        prefs.remove('selected_account_id');
      }
    } catch (e) {
      print(e);
    }

    try {
      final currentLanguageCode = prefs.getString('selected_language');
      if (currentLanguageCode != null) {
        prefs.setString("currentLanguageCode", currentLanguageCode);
        prefs.remove('selected_language');
      }
    } catch (e) {
      print(e);
    }

    try {
      final currentMembershipID = prefs.getString('selected_membership_id');
      if (currentMembershipID != null) {
        prefs.setString("currentMembershipID", currentMembershipID);
        prefs.remove('selected_membership_id');
      }
    } catch (e) {
      print(e);
    }

    try {
      final defaultFreeSlots = prefs.getInt('/userpref_defaultFreeSlots');
      if (defaultFreeSlots != null) {
        prefs.setInt("defaultFreeSlots", defaultFreeSlots);
        prefs.remove('/userpref_defaultFreeSlots');
      }
    } catch (e) {
      print(e);
    }

    try {
      final hasTappedGhost = prefs.getBool('/userpref_hasTappedGhost');
      if (hasTappedGhost != null) {
        prefs.setBool("hasTappedGhost", hasTappedGhost);
        prefs.remove('/userpref_hasTappedGhost');
      }
    } catch (e) {
      print(e);
    }

    try {
      final keepAwake = prefs.getBool('/userpref_keepAwake');
      if (keepAwake != null) {
        prefs.setBool("keepAwake", keepAwake);
        prefs.remove('/userpref_keepAwake');
      }
    } catch (e) {
      print(e);
    }

    try {
      final accountIDs = prefs.getStringList('account_ids');
      if (accountIDs != null) {
        await File("$storageRoot/accountIDs.json").writeAsString(jsonEncode(accountIDs));
      }
    } catch (e) {
      print(e);
    }

    try {
      final accounts = Directory("$storageRoot/accounts").listSync();
      for (final account in accounts) {
        final stat = await account.stat();
        if (stat.type != FileSystemEntityType.directory) continue;
        try {
          await File("${account.path}/memberships.json").rename("${account.path}/membershipData.json");
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }

    /*TODO: migrations
        migrate tracked objectives
        migrate character order
        migrate item order
        migrate pursuit order
    */
    prefs.remove("/currentVersion");
    prefs.remove("/versionUpdatedDate");
    await tryDelete("$storageRoot/bungie_common_settings.json");
    await tryDelete("$storageRoot/parsedWishlists.json");
    await tryDelete("$storageRoot/rawData", true);
    await tryDelete("$storageRoot/rawWishlists", true);
    await tryDelete("$storageRoot/wishlists.json", true);
    await tryDelete("$storageRoot/languages", true);
    await tryDelete("$dbRoot/languages", true);
  }
}
