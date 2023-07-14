import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/models/transfer_destination.dart';
import 'action_notification.dart';

enum TransferSteps {
  PullFromPostmaster,
  Unequip,
  AllocateSpaceToPullFromPostmaster,
  MoveToVault,
  AllocateSpaceToMoveToCharacter,
  MoveToCharacter,
  EquipOnCharacter,
}

class TransferNotification extends ActionNotification {
  final TransferDestination source;
  final TransferDestination destination;
  Set<TransferSteps>? _steps;
  TransferSteps? _currentStep;
  final List<TransferNotification> _sideEffects = [];

  TransferNotification({
    required DestinyItemInfo item,
    required this.source,
    required this.destination,
  }) : super(item: item);

  @override
  String get id => "transfer-action-${item.itemHash}-${item.instanceId}-${createdAt.millisecondsSinceEpoch}";

  TransferNotification createSideEffect({
    required DestinyItemInfo item,
    required TransferDestination source,
    required TransferDestination destination,
    bool unequip = false,
  }) {
    final action = TransferNotification(item: item, source: source, destination: destination);
    if (unequip) {
      action.createSteps(isEquipped: true);
    }
    _sideEffects.add(action);
    action.addListener(dispatchSideEffects);
    return action;
  }

  TransferSteps? get currentStep => _currentStep;

  List<TransferNotification> get sideEffects => _sideEffects;

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

  @override
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

  void dispatchSideEffects() {
    notifyListeners();
  }

  @override
  bool get active => _steps != null;
}
