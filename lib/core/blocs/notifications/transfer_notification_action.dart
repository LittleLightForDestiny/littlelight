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
  final DateTime _createdAt;

  SingleTransferAction({required this.item, required this.sourceCharacter, required this.destinationCharacter})
      : _createdAt = DateTime.now();

  set currentStep(TransferSteps? step) {
    _currentStep = step;
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
    _steps = {
      if (isOnPostmaster) TransferSteps.PullFromPostmaster,
      if (isEquipped) TransferSteps.Unequip,
      if (moveToVault) TransferSteps.MoveToVault,
      if (moveToCharacter) TransferSteps.MoveToCharacter,
      if (equipOnCharacter) TransferSteps.EquipOnCharacter,
    };
    notifyListeners();
  }

  bool hasSteps(Set<TransferSteps> steps) => steps.any((step) => _steps?.contains(step) ?? false);

  bool get active => _steps != null;

  @override
  String get id =>
      "transfer-action-${item.item.itemHash}-${item.item.itemInstanceId}-${_createdAt.millisecondsSinceEpoch}";

  bool get finishedWithSuccess => _isFinished;
  bool get shouldPlayDismissAnimation => _shouldPlayDismissAnimation;
  bool get dismissAnimationFinished => _dismissAnimationFinished;
  bool get hasError => _transferErrorMessage != null;
  String? get errorMessage => _transferErrorMessage;
  void error(String message) async {
    _transferErrorMessage = message;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 4));
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    dismiss();
  }

  void success() async {
    _isFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    dismiss();
  }
}
