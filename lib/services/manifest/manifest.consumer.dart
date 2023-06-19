import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:provider/provider.dart';

ManifestService getInjectedManifestService() => GetIt.I<ManifestService>();

mixin ManifestConsumer {
  ManifestService get manifest => getInjectedManifestService();
}

extension ManifestProvider on BuildContext {
  T? definition<T>(hash, {bool useReadContext = false}) => useReadContext
      ? this.read<ManifestService>().definition<T>(hash)
      : this.select<ManifestService, T?>((m) => m.definition<T>(hash));
}
