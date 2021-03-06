import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QueuedNetworkImage extends StatelessWidget {
  static int maxNrOfCacheObjects;
  static Duration inBetweenCleans;
  final String imageUrl;
  final Alignment alignment;
  final Widget placeholder;
  final Duration fadeInDuration;
  final BoxFit fit;

  QueuedNetworkImage(
      {this.imageUrl,
      this.placeholder,
      this.fit: BoxFit.contain,
      this.alignment = Alignment.center,
      this.fadeInDuration,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      placeholderFadeInDuration: Duration(seconds: 2),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          placeholder ?? Container(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
