import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_item.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/services/analytics/analytics.service.dart';
import 'package:provider/provider.dart';

const _baseUrl = 'https://fastly.jsdelivr.net/gh/Database-Clarity/Live-Clarity-Database@live/';
const _liveDataPath = 'descriptions/clarity.json';

class ClarityDataBloc extends ChangeNotifier {
  @protected
  final LanguageBloc languageBloc;

  @protected
  final AnalyticsService analytics;

  @protected
  final UserSettingsBloc userSettings;

  ClarityDataBloc(BuildContext context)
      : languageBloc = context.read<LanguageBloc>(),
        analytics = context.read<AnalyticsService>(),
        userSettings = context.read<UserSettingsBloc>();

  bool isLoading = false;
  Map<int, ClarityItem>? _liveData;

  Map<int, ClarityItem>? get liveData {
    if (_liveData != null) return _liveData;
    if (isLoading) return null;
    if (!userSettings.showClarityInsights) return null;
    _loadLiveData();
    return null;
  }

  Future<void> _loadLiveData() async {
    if (isLoading) return;
    final liveDataUrl = _baseUrl + _liveDataPath;
    try {
      isLoading = true;
      final res = await http.get(Uri.parse(liveDataUrl));
      final raw = res.body;
      final json = jsonDecode(raw);
      final result = <int, ClarityItem>{};
      final keys = json.keys;
      for (final key in keys) {
        final hash = int.tryParse(key);
        if (hash == null) continue;
        result[hash] = ClarityItem.fromJson(json[key]);
      }
      _liveData = result;
      isLoading = false;
    } catch (e, stackTrace) {
      analytics.registerNonFatal(e, stackTrace);
    }

    notifyListeners();
  }

  List<ClarityDescription>? getPerkDescriptions(int? plugHash) {
    if (!userSettings.showClarityInsights) return null;
    final item = liveData?[plugHash];
    if (item == null) return null;
    final descriptions = item.descriptions;
    if (descriptions == null) return null;
    final language = this.languageBloc.currentLanguage;
    if (descriptions[language] != null) return descriptions[language];
    if (descriptions['en'] != null) return descriptions['en'];
    return descriptions.values.firstOrNull;
  }
}
