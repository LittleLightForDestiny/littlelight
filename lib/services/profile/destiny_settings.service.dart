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
    }
    _currentSeasonPassDef = await ManifestService().getDefinition<DestinySeasonPassDefinition>(seasonDef.seasonPassHash);
  }

  int get seasonalRankProgressionHash{
    return _currentSeasonPassDef?.rewardProgressionHash;
  }

  int get seasonalPrestigeRankProgressionHash{
    return _currentSeasonPassDef?.prestigeProgressionHash;
  }

}
