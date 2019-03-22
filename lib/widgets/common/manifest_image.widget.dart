import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:shimmer/shimmer.dart';

typedef ExtractUrlFromData<T> = String Function(T definition);

class ManifestImageWidget<T> extends StatefulWidget {
  final int hash;
  final ExtractUrlFromData<T> urlExtractor;
  final ManifestService _manifest = new ManifestService();

  final Widget placeholder;

  final BoxFit fit;
  final Alignment alignment;

  ManifestImageWidget(this.hash,
      {Key key,
      this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.urlExtractor,
      this.placeholder})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ManifestImageState<T>();
  }
}

class ManifestImageState<T> extends State<ManifestImageWidget<T>> {
  T definition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    definition =
        await widget._manifest.getDefinition<T>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Shimmer shimmer = ShimmerHelper.getDefaultShimmer(context);
    if(definition == null) return shimmer;
    String url = "";
    try {
      if (widget.urlExtractor == null) {
        url = (definition as dynamic).displayProperties.icon;
      } else {
        url = widget.urlExtractor(definition);
      }
    } catch (e) {
      print(e);
    }
    if(url == null || url.length == 0){
      return shimmer;
    }
    return QueuedNetworkImage(
      imageUrl: BungieApiService.url(url),
      fit: widget.fit,
      alignment: widget.alignment,
      placeholder: widget.placeholder ?? shimmer,
      fadeInDuration: Duration(milliseconds: 300),
    );
  }
}
