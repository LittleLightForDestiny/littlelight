import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef ExtractUrlFromData<T> = String? Function(T definition);

class _ManifestImageState<T> {
  final T? definition;
  final bool finished;

  _ManifestImageState(this.definition, this.finished);
}

class ManifestImageWidget<T> extends StatelessWidget with ManifestConsumer {
  final int? hash;
  final ExtractUrlFromData<T>? urlExtractor;

  final Widget? placeholder;
  final Widget? noIconPlaceholder;

  final BoxFit fit;
  final Alignment alignment;

  ManifestImageWidget(this.hash,
      {Key? key,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.urlExtractor,
      this.placeholder,
      this.noIconPlaceholder})
      : super(key: key);

  Future<_ManifestImageState<T>> get future async {
    final def = await manifest.getDefinition<T>(hash);
    return _ManifestImageState(def, true);
  }

  Widget buildShimmer(BuildContext context) => DefaultLoadingShimmer();

  Widget buildPlaceholder(BuildContext context) => placeholder ?? buildShimmer(context);

  String? getUrl(BuildContext context, T definition) {
    if (urlExtractor != null) return urlExtractor!(definition);
    return (definition as dynamic).displayProperties?.icon;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ManifestImageState<T>>(
      initialData: _ManifestImageState(null, false),
      future: future,
      builder: (context, snapshot) {
        final loaded = snapshot.data?.finished ?? false;
        final definition = snapshot.data?.definition;
        if (!loaded) return buildPlaceholder(context);
        if (definition == null) return noIconPlaceholder ?? buildPlaceholder(context);

        final url = getUrl(context, definition);
        final bungieUrl = BungieApiService.url(url);
        if (bungieUrl == null || bungieUrl.isEmpty) return noIconPlaceholder ?? buildPlaceholder(context);
        return QueuedNetworkImage(
          imageUrl: bungieUrl,
          fit: fit,
          alignment: alignment,
          placeholder: buildPlaceholder(context),
          fadeInDuration: Duration(milliseconds: 300),
        );
      },
    );
  }
}
