import 'package:little_light/core/blocs/notifications/item_action_notification.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

enum PlugStatus { Applying, Success, Fail }

class ApplyPlugsNotification extends ItemActionNotification {
  Map<int, int>? _plugs;
  final Map<int, PlugStatus> _statuses = {};

  ApplyPlugsNotification({required DestinyItemInfo item}) : super(item: item);

  @override
  String get id => "apply-mods-${item.itemHash}-${item.instanceId}-${createdAt.millisecondsSinceEpoch}";

  @override
  double get progress {
    return 0;
  }

  void dispatchSideEffects() {
    notifyListeners();
  }

  @override
  bool get active => _plugs != null;

  void setPlugs(Map<int, int> plugs) {
    this._plugs = plugs;
    this._statuses.addAll(plugs.map((key, value) => MapEntry(key, PlugStatus.Applying)));
    notifyListeners();
  }

  void setPlugStatus(int socketIndex, PlugStatus status) {
    this._statuses[socketIndex] = status;
    notifyListeners();
  }

  Map<int, PlugStatus> get plugs {
    final plugs = <int, PlugStatus>{};
    final hashes = _plugs;
    if (hashes != null) {
      for (final plug in hashes.entries) {
        final hash = plug.value;
        final status = _statuses[plug.key] ?? PlugStatus.Applying;
        plugs[hash] = status;
      }
    }
    return plugs;
  }
}
