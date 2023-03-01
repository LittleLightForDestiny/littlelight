import 'package:flutter/foundation.dart';

class OfflineModeBloc extends ChangeNotifier {
  bool _offlineMode = false;
  bool get isOffline => _offlineMode;
  void acceptOfflineMode() {
    _offlineMode = true;
    notifyListeners();
  }
}
