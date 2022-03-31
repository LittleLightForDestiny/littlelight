//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:shimmer/shimmer.dart';

typedef ExtractUrlFromData<T> = String? Function(T definition);

class ManifestImageWidget<T> extends StatefulWidget {
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

  @override
  State<StatefulWidget> createState() {
    return ManifestImageState<T>();
  }
}

class ManifestImageState<T> extends State<ManifestImageWidget<T>> with ManifestConsumer {
  T? definition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    if (widget.hash == null) return;
    definition = await manifest.getDefinition<T>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Shimmer shimmer = ShimmerHelper.getDefaultShimmer(context);
    final definition = this.definition;
    if (definition == null) return shimmer;
    String? url;
    try {
      final extractor = widget.urlExtractor;
      if (extractor == null) {
        url = (definition as dynamic).displayProperties.icon;
      } else {
        url = extractor(definition);
      }
    } catch (e) {
      print(e);
    }
    if (url?.isEmpty ?? true) {
      return widget.noIconPlaceholder ?? widget.placeholder ?? shimmer;
    }
    final bungieUrl = BungieApiService.url(url);
    if (bungieUrl == null) {
      return shimmer;
    }
    return QueuedNetworkImage(
      imageUrl: bungieUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      placeholder: widget.placeholder ?? shimmer,
      fadeInDuration: Duration(milliseconds: 300),
    );
  }
}
