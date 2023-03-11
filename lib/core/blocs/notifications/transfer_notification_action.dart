import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/models/transfer_destination.dart';

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
  final TransferDestination source;
  final TransferDestination destination;
  final DestinyItemInfo item;
  Set<TransferSteps>? _steps;
  TransferSteps? _currentStep;
  bool _isFinished = false;
  bool _shouldPlayDismissAnimation = false;
  bool _dismissAnimationFinished = false;
  String? _transferErrorMessage;
  final DateTime _createdAt;
  final List<SingleTransferAction> _sideEffects = [];

  SingleTransferAction({required this.item, required this.source, required this.destination})
      : _createdAt = DateTime.now();

  double get progress {
    final steps = _steps;
    final currentStep = _currentStep;
    if (steps == null || currentStep == null) return 0;
    final stepsOrder = TransferSteps.values.where((element) => _steps?.contains(element) ?? false).toList();
    final progress = stepsOrder.indexOf(currentStep);
    return progress / (stepsOrder.length - 1);
  }

  set currentStep(TransferSteps? step) {
    _currentStep = step;
    notifyListeners();
  }

  TransferSteps? get currentStep => _currentStep;

  List<SingleTransferAction> get sideEffects => _sideEffects;

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

  SingleTransferAction createSideEffect({
    required DestinyItemInfo item,
    required TransferDestination source,
    required TransferDestination destination,
    bool unequip = false,
  }) {
    final action = SingleTransferAction(item: item, source: source, destination: destination);
    if (unequip) {
      action.createSteps(isEquipped: true);
    }
    _sideEffects.add(action);
    action.addListener(dispatchSideEffects);
    return action;
  }

  void dispatchSideEffects() {
    notifyListeners();
  }
}
