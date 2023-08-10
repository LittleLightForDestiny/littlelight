import 'package:json_annotation/json_annotation.dart';

enum ClarityStatType {
  @JsonValue('Handling')
  Handling,
  @JsonValue('PVE Damage')
  PVEDamage,
  @JsonValue('PVP Damage')
  PVPDamage,
  @JsonValue('Aim Assist')
  AimAssist,
  @JsonValue('Range')
  Range,
  @JsonValue('Reload')
  Reload,
  @JsonValue('Charge Draw')
  ChargeDraw,
  @JsonValue('Airborne')
  Airborne,
  @JsonValue('Stability')
  Stability,
  @JsonValue('Guard Endurance')
  GuardEndurance,
  @JsonValue('Stow')
  Stow,
  @JsonValue('ADS')
  AimDownSight,
  @JsonValue('Guard Charge Rate')
  GuardChargeRate,
  @JsonValue('Ready')
  Ready,
  @JsonValue('Damage')
  Damage,
  @JsonValue('Guard Resistance')
  GuardResistance,
  @JsonValue('Firing Delay')
  FiringDelay,
  @JsonValue('Guard Efficiency')
  GuardEfficiency,
  @JsonValue('Zoom')
  Zoom,
  @JsonValue('Blast Radius')
  BlastRadius,
  Unknown,
}
