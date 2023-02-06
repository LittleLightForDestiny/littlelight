import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';

import 'base_notification_action.dart';

enum TransferSteps {
  PullFromPostmaster,
  Unequip,
  AllocateSpaceToPullFromPostmaster,
  MoveToVault,
  AllocateSpaceToMoveToCharacter,
  MoveToCharacter,
  EquipOnCharacter,
}

class SingleTransferAction extends BaseNotificationAction {
  final DestinyCharacterInfo? sourceCharacter;
  final DestinyCharacterInfo? destinationCharacter;
  final DestinyItemInfo item;
  Set<TransferSteps>? _steps;
  TransferSteps? _currentStep;
  bool _isFinished = false;
  bool _shouldPlayDismissAnimation = false;
  bool _dismissAnimationFinished = false;
  String? _transferErrorMessage;

  SingleTransferAction({required this.item, required this.sourceCharacter, required this.destinationCharacter});

  set currentStep(TransferSteps? step) {
    this._currentStep = step;
    notifyListeners();
  }

  TransferSteps? get currentStep => _currentStep;

  void createSteps({
    bool isOnPostmaster = false,
    bool isEquipped = false,
    bool moveToVault = false,
    bool moveToCharacter = false,
    bool equipOnCharacter = false,
  }) {
    this._steps = {
      if (isOnPostmaster) TransferSteps.PullFromPostmaster,
      if (isEquipped) TransferSteps.Unequip,
      if (moveToVault) TransferSteps.MoveToVault,
      if (moveToCharacter) TransferSteps.MoveToCharacter,
      if (equipOnCharacter) TransferSteps.EquipOnCharacter,
    };
    notifyListeners();
  }

  bool hasSteps(Set<TransferSteps> steps) => steps.any((step) => _steps?.contains(step) ?? false);

  bool get active => this._steps != null;

  String get id => "transfer-action-${item.item.itemHash}-${item.item.itemInstanceId}";

  bool get isFinished => _isFinished;
  bool get shouldPlayDismissAnimation => _shouldPlayDismissAnimation;
  bool get dismissAnimationFinished => _dismissAnimationFinished;
  bool get hasError => _transferErrorMessage != null;
  String? get errorMessage => _transferErrorMessage;
  void error(String message) {
    this._transferErrorMessage = message;
    notifyListeners();
  }

  void success() async {
    this._isFinished = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 3));
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 200));
    this.dismiss();
  }
}
