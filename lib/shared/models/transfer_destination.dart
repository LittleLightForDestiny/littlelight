import 'package:little_light/core/blocs/profile/destiny_character_info.dart';

enum TransferDestinationType {
  character,
  vault,
  profile,
}

class TransferDestination {
  TransferDestinationType type;
  DestinyCharacterInfo? character;

  TransferDestination(this.type, {this.character});

  TransferDestination.vault() : this.type = TransferDestinationType.vault;
  TransferDestination.profile() : this.type = TransferDestinationType.profile;

  String? get characterId => this.character?.characterId;

  String get id => "$type-$characterId";

  @override
  bool operator ==(Object other) => other is TransferDestination && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
