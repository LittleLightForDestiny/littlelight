import 'package:little_light/models/destiny_loadout.dart';

import 'action_notification.dart';

class EquipDestinyLoadoutNotification extends ActionNotification {
  final DestinyLoadoutInfo loadout;

  EquipDestinyLoadoutNotification({required DestinyLoadoutInfo this.loadout}) : super();

  @override
  String get id => "equip-destiny-loadout-action-${loadout.index}";

  @override
  bool get active => true;

  @override
  double get progress => 0;

  @override
  int? get targetHash => loadout.index;
}
