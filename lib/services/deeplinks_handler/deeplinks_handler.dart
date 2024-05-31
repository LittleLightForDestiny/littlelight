import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:protocol_registry/protocol_registry.dart';

class DeeplinksHandler extends ChangeNotifier {
  Uri? _currentLink;
  StreamSubscription<Uri>? _appLinksSubscription;

  DeeplinksHandler() {
    // Android is already handling deeplinks by itself
    if (Platform.isAndroid) return;
    // iOS is already handling deeplinks by itself
    if (Platform.isIOS) return;
    final _appLinks = AppLinks();
    _appLinksSubscription = _appLinks.uriLinkStream.listen(_linkListener);
    registerProtocol();
  }

  void registerProtocol() async {
    if (!Platform.isWindows) return;
    final ProtocolRegistryModel registry = getRegistry();
    await registry.add(ProtocolScheme(scheme: 'luzinha', appPath: Platform.resolvedExecutable));
    final exists = await registry.exists(ProtocolScheme(scheme: 'luzinha'));
    print("exists: $exists");
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
