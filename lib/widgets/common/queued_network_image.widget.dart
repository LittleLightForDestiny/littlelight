//@dart=2.12
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QueuedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Alignment alignment;
  final Widget? placeholder;
  final Duration? fadeInDuration;
  final BoxFit fit;

  QueuedNetworkImage(
      {required this.imageUrl,
      this.placeholder,
      this.fit: BoxFit.contain,
      this.alignment = Alignment.center,
      this.fadeInDuration,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      placeholderFadeInDuration: fadeInDuration ?? Duration(seconds: 2),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          placeholder ?? Container(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
