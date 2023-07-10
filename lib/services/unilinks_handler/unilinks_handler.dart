import 'dart:io';

import 'package:flutter/material.dart';
import 'package:little_light/services/setup.dart';
import 'package:uni_links/uni_links.dart';

bool get _enabled => !Platform.isAndroid;

class UnilinksHandler extends ChangeNotifier {
  Uri? _currentLink;
  UnilinksHandler() {
    if (!_enabled) return;
    _asyncInit();
  }

  _asyncInit() async {
    uriLinkStream.listen(_linkListener);
  }

  _linkListener(Uri? event) async {
    _currentLink = event;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 500));
    // _currentLink = null;
  }

  Uri? get currentLink {
    final value = _currentLink;
    return value;
  }
}
