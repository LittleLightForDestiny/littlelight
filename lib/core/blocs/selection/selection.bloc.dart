import 'package:flutter/material.dart';

class SelectionBloc extends ChangeNotifier {
  Map<int, Set<String?>> _selectedItems = {};

  void selectItem(int hash, String? instanceId) {
    final instances = _selectedItems[hash] ?? Set();
    instances.add(instanceId);
    notifyListeners();
  }

  void unselectItem(int hash, String? instanceId) {
    _selectedItems[hash]?.remove(instanceId);
    notifyListeners();
  }

  void clear() {
    _selectedItems = {};
    notifyListeners();
  }

  bool isSelected(int hash, String? instanceId) {
    return _selectedItems[hash]?.contains(instanceId) ?? false;
  }

  bool get hasSelection {
    return _selectedItems.values.any((e) => e.length > 0);
  }
}
