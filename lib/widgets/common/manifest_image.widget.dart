import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

typedef ExtractUrlFromData<T> = String? Function(T definition);

class ManifestImageWidget<T> extends StatelessWidget with ManifestConsumer {
  final int? definitionHash;
  final ExtractUrlFromData<T>? urlExtractor;

  final Widget? placeholder;
  final Widget? noIconPlaceholder;

  final BoxFit fit;
  final Alignment alignment;

  final Color? color;

  ManifestImageWidget(
    this.definitionHash, {
    Key? key,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.urlExtractor,
    this.placeholder,
    this.noIconPlaceholder,
    this.color,
  }) : super(key: key);

  Widget buildShimmer(BuildContext context) => const DefaultLoadingShimmer();

  Widget buildPlaceholder(BuildContext context) => placeholder ?? buildShimmer(context);

  String? getUrl(BuildContext context, T definition) {
    if (urlExtractor != null) return urlExtractor!(definition);
    return (definition as dynamic).displayProperties?.icon;
  }

  @override
  Widget build(BuildContext context) {
    final definition = context.definition<T>(definitionHash);
    if (definition == null) return buildPlaceholder(context);
    final url = getUrl(context, definition);
    final bungieUrl = BungieApiService.url(url);
    if (bungieUrl == null || bungieUrl.isEmpty) return noIconPlaceholder ?? buildPlaceholder(context);
    return QueuedNetworkImage(
      imageUrl: bungieUrl,
      fit: fit,
      alignment: alignment,
      placeholder: buildPlaceholder(context),
      fadeInDuration: const Duration(milliseconds: 300),
      color: color,
    );
  }
}
