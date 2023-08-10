import 'package:json_annotation/json_annotation.dart';

enum ClarityWeaponType {
  @JsonValue('Fusion')
  Fusion,
  @JsonValue('AR')
  AutoRifle,
  @JsonValue('LMG')
  MachineGun,
  @JsonValue('Pulse')
  PulseRifle,
  @JsonValue('Trace')
  TraceRifle,
  @JsonValue('LFR')
  LinearFusionRifle,
  @JsonValue('Bow')
  Bow,
  @JsonValue('Glaive')
  Glaive,
  @JsonValue('HC')
  HandCannon,
  @JsonValue('Scout')
  ScoutRifle,
  @JsonValue('GL')
  GrenadeLauncher,
  @JsonValue('Heavy GL')
  HeavyGrenadeLauncher,
  @JsonValue('Rocket')
  RocketLauncher,
  @JsonValue('Shotgun')
  Shotgun,
  @JsonValue('Sidearm')
  Sidearm,
  @JsonValue('SMG')
  SubMachineGun,
  @JsonValue('Sniper')
  SniperRifle,
  @JsonValue('Sword')
  Sword,
  @JsonValue('Grenade')
  Grenade,
  @JsonValue('Melee')
  Melee,
  @JsonValue('Super')
  Super,
  Unknown,
}
