import 'dart:async';

import 'package:flutter/material.dart';

abstract class StorableValue<V> {
  Object key;
  V? value;

  StorableValue(Object this.key, [V? this.value]);

  @override
  bool operator ==(Object other) => other is StorableValue && other.runtimeType == runtimeType && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

class ScopedValueRepositoryBloc extends ChangeNotifier {
  Timer? _updateDebouncer;

  final Map<Type, Map<Object, StorableValue>> _repository = {};
  void storeValue<T extends StorableValue>(T param) {
    final typeRepo = _repository[T] ??= {};
    final currentValue = typeRepo[param.key]?.value;
    if (param.value == currentValue) return;
    typeRepo[param.key] = param;
    _asyncUpdate();
  }

  void _asyncUpdate() async {
    _updateDebouncer?.cancel();
    _updateDebouncer = new Timer(Duration(milliseconds: 10), () {
      notifyListeners();
    });
  }

  T? getValue<T extends StorableValue>(T param) {
    return _repository[T]?[param.key] as T;
  }
}
