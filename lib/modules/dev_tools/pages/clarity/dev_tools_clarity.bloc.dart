import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/clarity/clarity_data.bloc.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_item.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:provider/provider.dart';

class DevToolsClarityBloc extends ChangeNotifier {
  @protected
  final BuildContext context;

  final ProfileBloc _profile;
  final ClarityDataBloc _clarity;

  List<ClarityItem>? allItems;
  List<ClarityItem>? get items => allItems;
  Set<String>? types;

  DevToolsClarityBloc(this.context)
      : _profile = context.read<ProfileBloc>(),
        _clarity = context.read<ClarityDataBloc>(),
        super() {
    init();
  }

  init() {
    _profile.addListener(_update);
    _clarity.addListener(_update);
    _update();
  }

  dispose() {
    _profile.removeListener(_update);
    _clarity.removeListener(_update);
    super.dispose();
  }

  _update() async {
    final items = this.items;
    if (items == null) return;
    final keys = <dynamic>{};
    for (final item in items) {
      final stats = item.stats;
      if (stats == null) continue;
      for (final statList in stats.values) {
        for (final s in statList) {
          keys.addAll(s.active?.keys ?? {});
          keys.addAll(s.passive?.keys ?? {});
        }
      }
      // final descriptions = item.descriptions;
      // if (descriptions == null) continue;
      // for (final description in descriptions.values) {
      //   for (final d in description) {
      //     final lineContents = d.linesContent ?? <D2ClarityLineContent>[];
      //     for (final l in lineContents) {
      //       keys.add(l.formula);
      //     }
      //   }
      // }
    }
    print(keys);
    notifyListeners();
  }

  load() async {
    final items = _clarity.liveData;
    this.allItems = items?.values.toList();
    _update();
  }
}
