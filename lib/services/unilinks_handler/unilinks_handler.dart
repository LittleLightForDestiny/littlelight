import 'dart:io';
import 'package:flutter/material.dart';
import 'package:little_light/services/setup.dart';
import 'package:uni_links_platform_interface/uni_links_platform_interface.dart';

bool get _enabled => Platform.isAndroid;

setupUnilinksHandler() async {
  if (_enabled) return;
  if (!getItCoreInstance.isRegistered<UnilinksHandler>()) {
    getItCoreInstance.registerSingleton<UnilinksHandler>(UnilinksHandler._internal());
  }
}

class UnilinksHandler extends ChangeNotifier {
  String? _currentLink;
  UnilinksHandler._internal() {
    if (_enabled) return;
    _asyncInit();
  }

  _asyncInit() async {
    UniLinksPlatform.instance.linkStream.listen((event) {
      _currentLink = event;
      notifyListeners();
    });
  }

  String? get currentLink {
    final value = _currentLink;
    _currentLink = null;
    return value;
  }
}
