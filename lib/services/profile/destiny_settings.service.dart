import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_season_definition.dart';
import 'package:bungie_api/models/destiny_season_pass_definition.dart';
import 'package:get_it/get_it.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/storage/export.dart';

setupDestinySettingsService() {
  GetIt.I.registerSingleton<DestinySettingsService>(DestinySettingsService._internal());
}

class DestinySettingsService with StorageConsumer, BungieApiConsumer, ManifestConsumer {
  DateTime? lastUpdated;

  DestinySettingsService._internal();

  CoreSettingsConfiguration? _currentSettings;
  DestinySeasonPassDefinition? _currentSeasonPassDef;

  static const int SeasonLevel = 3733477714;
  static const int SeasonOverlevel = 2140885848;

  init() async {
    var settings = await globalStorage.getBungieCommonSettings();
    var seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
    var seasonDef = await manifest.getDefinition<DestinySeasonDefinition>(seasonHash);
    final endDateStr = seasonDef?.endDate;
    final seasonEnd = endDateStr != null ? DateTime.parse(endDateStr) : DateTime.fromMillisecondsSinceEpoch(0);
    final now = DateTime.now();
    if (now.isAfter(seasonEnd)) {
      logger.info("loaded settings from web");
      settings = await bungieAPI.getCommonSettings();
      seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
      seasonDef = await manifest.getDefinition<DestinySeasonDefinition>(seasonHash);
      await globalStorage.setBungieCommonSettings(settings);
    }
    var seasonPassHash = seasonDef?.seasonPassHash;
    if (seasonPassHash == null) {
      seasonPassHash = seasonDef?.seasonPassList?.where((e) {
        final seasonPassStartDate = e.seasonPassStartDate;
        final seasonPassEndDate = e.seasonPassEndDate;
        if (seasonPassStartDate == null || seasonPassEndDate == null) return false;
        final seasonPassStart = DateTime.parse(seasonPassStartDate);
        final seasonPassEnd = DateTime.parse(seasonPassEndDate);
        return now.isAfter(seasonPassStart) && now.isBefore(seasonPassEnd);
      })
      .map((e) => e.seasonPassHash)
      .firstOrNull;
    }
    _currentSettings = settings;
    _currentSeasonPassDef = await manifest.getDefinition<DestinySeasonPassDefinition>(seasonPassHash);
  }

  int? get seasonalRankProgressionHash {
    return _currentSeasonPassDef?.rewardProgressionHash;
  }

  int? get seasonalPrestigeRankProgressionHash {
    return _currentSeasonPassDef?.prestigeProgressionHash;
  }

  int? get collectionsRootNode {
    return _currentSettings?.destiny2CoreSettings?.collectionRootNode;
  }

  int? get badgesRootNode {
    return _currentSettings?.destiny2CoreSettings?.badgesRootNode;
  }

  int? get triumphsRootNode {
    return _currentSettings?.destiny2CoreSettings?.activeTriumphsRootNodeHash;
  }

  int? get legacyTriumphsRootNode {
    return _currentSettings?.destiny2CoreSettings?.legacyTriumphsRootNodeHash;
  }

  int? get loreRootNode {
    return _currentSettings?.destiny2CoreSettings?.loreRootNodeHash;
  }

  int? get medalsRootNode {
    return _currentSettings?.destiny2CoreSettings?.medalsRootNodeHash;
  }

  int? get statsRootNode {
    return _currentSettings?.destiny2CoreSettings?.metricsRootNode;
  }

  int? get sealsRootNode {
    return _currentSettings?.destiny2CoreSettings?.medalsRootNode;
  }

  int? get legacySealsRootNode {
    return _currentSettings?.destiny2CoreSettings?.legacySealsRootNodeHash;
  }

  int? get catalystsRootNode {
    return _currentSettings?.destiny2CoreSettings?.exoticCatalystsRootNodeHash;
  }
}
