import 'package:flutter/material.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';

class _GlobalKeyHolder extends StorableValue<GlobalKey> {
  _GlobalKeyHolder(String super.key, [super.value]);
}

extension GlobalKeyHolder on BuildContext {
  GlobalKey getGlobalKeyFor(String identifier) {
    _GlobalKeyHolder? keyValue = this.readValue<_GlobalKeyHolder>(_GlobalKeyHolder(identifier));
    GlobalKey globalKey = keyValue?.value ?? GlobalKey();
    if (keyValue == null) {
      this.storeValue(_GlobalKeyHolder(identifier, globalKey));
    }
    return globalKey;
  }
}
