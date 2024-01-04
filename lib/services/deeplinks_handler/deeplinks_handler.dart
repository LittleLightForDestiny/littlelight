import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeeplinksHandler extends ChangeNotifier {
  Uri? _currentLink;
  StreamSubscription<Uri>? _appLinksSubscription;

  DeeplinksHandler() {
    final _appLinks = AppLinks();
    _appLinksSubscription = _appLinks.allUriLinkStream.listen(_linkListener);
  }

  @override
  dispose() {
    _appLinksSubscription?.cancel();
    super.dispose();
  }

  _linkListener(Uri? event) async {
    _currentLink = event;
    notifyListeners();
  }

  Uri? get currentLink {
    final value = _currentLink;
    return value;
  }
}
