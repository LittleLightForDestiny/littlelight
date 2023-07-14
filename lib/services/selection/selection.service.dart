import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:little_light/utils/item_with_owner.dart';

setupSelectionService() {
  GetIt.I.registerLazySingleton(() => SelectionService._internal());
}

class SelectionService {
  SelectionService._internal();

  final List<ItemWithOwner> _selectedItems = [];

  Stream<List<ItemWithOwner>>? _eventsStream;
  final StreamController<List<ItemWithOwner>> _streamController = StreamController.broadcast();

  List<ItemWithOwner> get items => _selectedItems;

  bool _multiSelectActivated = false;
  bool get multiselectActivated => _multiSelectActivated;

  activateMultiSelect() {
    _multiSelectActivated = true;
  }

  Stream<List<ItemWithOwner>>? get broadcaster {
    if (_eventsStream != null) {
      return _eventsStream;
    }
    _eventsStream = _streamController.stream;
    return _eventsStream;
  }

  _onUpdate() {
    _streamController.add(_selectedItems);
  }

  isSelected(ItemWithOwner item) {
    // final itemHash = item.itemHash;
    // final itemInstanceId = item.instanceId;
    // return _selectedItems.any(
    //     (i) => i.item.itemHash == itemHash && i.ownerId == item.ownerId && i.item.itemInstanceId == itemInstanceId);
  }

  setItem(ItemWithOwner item) {
    _selectedItems.clear();
    _selectedItems.add(item);
    _onUpdate();
  }

  addItem(ItemWithOwner item) {
    // ItemWithOwner? alreadyAdded = _selectedItems.firstWhereOrNull((i) {
    //   if (item.instanceId != null) {
    //     return i.item.itemInstanceId == item.instanceId;
    //   }
    //   return i.item.itemHash == item.itemHash && i.ownerId == item.ownerId;
    // });
    // if (alreadyAdded != null) {
    //   return removeItem(item);
    // }

    // _selectedItems.add(item);

    _onUpdate();
  }

  removeItem(ItemWithOwner item) {
    // if (item.instanceId != null) {
    //   _selectedItems.removeWhere((i) => i.item.itemInstanceId == item.instanceId);
    // } else {
    //   _selectedItems.removeWhere((i) => i.item.itemHash == item.itemHash && i.ownerId == item.ownerId);
    // }
    if (_selectedItems.isEmpty) {
      _multiSelectActivated = false;
    }
    _onUpdate();
  }

  clear() {
    _selectedItems.clear();
    _multiSelectActivated = false;
    _onUpdate();
  }
}
