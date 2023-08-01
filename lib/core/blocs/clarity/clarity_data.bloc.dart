import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/core/blocs/clarity/models/d2_clarity_item.dart';

const _baseUrl = 'https://raw.githubusercontent.com/Database-Clarity/Live-Clarity-Database/live/';
const _liveDataPath = 'descriptions/clarity.json';

class ClarityDataBloc extends ChangeNotifier {
  bool isLoading = false;
  Map<int, ClarityItem>? _liveData;

  Map<int, ClarityItem>? get liveData {
    if (_liveData != null) return _liveData;
    if (isLoading) return null;
    _loadLiveData();
    return null;
  }

  Future<void> _loadLiveData() async {
    if (isLoading) return;
    isLoading = true;
    final liveDataUrl = _baseUrl + _liveDataPath;
    try {
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
    } catch (e) {}
    isLoading = false;
    notifyListeners();
  }
}
