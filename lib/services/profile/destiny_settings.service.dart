import 'package:bungie_api/models/core_settings_configuration.dart';
import 'package:bungie_api/models/destiny_season_definition.dart';
import 'package:bungie_api/models/destiny_season_pass_definition.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

class DestinySettingsService {
  static final DestinySettingsService _singleton =
      new DestinySettingsService._internal();
  DateTime lastUpdated;
  factory DestinySettingsService() {
    return _singleton;
  }
  DestinySettingsService._internal();
  final _api = BungieApiService();

  CoreSettingsConfiguration _currentSettings;
  DestinySeasonPassDefinition _currentSeasonPassDef;

  static const int SeasonLevel = 3256821400;
  static const int SeasonOverlevel = 2140885848;

  init() async {
    var json = await StorageService.global().getJson(StorageKeys.bungieCommonSettings);
    var settings = CoreSettingsConfiguration.fromJson(json ?? {});
    var seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
    var seasonDef = await ManifestService().getDefinition<DestinySeasonDefinition>(seasonHash);
    var seasonEnd = seasonDef != null ? DateTime.parse(seasonDef?.endDate) : DateTime.fromMillisecondsSinceEpoch(0);
    var now = DateTime.now();
    if(now.isAfter(seasonEnd)){
      print("loaded settings from web");
      settings = await _api.getCommonSettings();
      seasonHash = settings?.destiny2CoreSettings?.currentSeasonHash;
      seasonDef = await ManifestService().getDefinition<DestinySeasonDefinition>(seasonHash);
      await StorageService.global().setJson(StorageKeys.bungieCommonSettings, settings.toJson());
    }
    _currentSettings = settings;
    _currentSeasonPassDef = await ManifestService().getDefinition<DestinySeasonPassDefinition>(seasonDef.seasonPassHash);
  }

  int get seasonalRankProgressionHash{
    return _currentSeasonPassDef?.rewardProgressionHash ?? 3256821400;
  }

  int get seasonalPrestigeRankProgressionHash{
    return _currentSeasonPassDef?.prestigeProgressionHash ?? 2140885848;
  }

  int get collectionsRootNode{
    return _currentSettings?.destiny2CoreSettings?.collectionRootNode ?? 3790247699;
  }

  int get badgesRootNode{
    return _currentSettings?.destiny2CoreSettings?.badgesRootNode ?? 498211331;
  }

  int get triumphsRootNode{
    return _currentSettings?.destiny2CoreSettings?.recordsRootNode ?? 1024788583;
  }

  int get sealsRootNode{
    return _currentSettings?.destiny2CoreSettings?.medalsRootNode ?? 1652422747;
  }
}
