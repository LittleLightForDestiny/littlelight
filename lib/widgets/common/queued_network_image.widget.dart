import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';

class QueuedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final Alignment alignment;
  final Widget? placeholder;
  final Duration? fadeInDuration;
  final BoxFit fit;
  final Color? color;

  const QueuedNetworkImage(
      {required this.imageUrl,
      this.placeholder,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.fadeInDuration,
      this.color,
      Key? key})
      : super(key: key);

  factory QueuedNetworkImage.fromBungie(
    String? relativeURL, {
    Widget? placeholder,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    Duration? fadeInDuration,
    Key? key,
    Color? color,
  }) =>
      QueuedNetworkImage(
        imageUrl: BungieApiService.url(relativeURL),
        placeholder: placeholder,
        fit: fit,
        alignment: alignment,
        fadeInDuration: fadeInDuration,
        key: key,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return placeholder ?? SizedBox();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      alignment: alignment,
      placeholderFadeInDuration: fadeInDuration ?? const Duration(seconds: 2),
      progressIndicatorBuilder: (context, url, downloadProgress) => placeholder ?? SizedBox(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      color: color,
    );
  }
}
