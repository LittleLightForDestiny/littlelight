import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';

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
    if(imageUrl == null){
      return Container();
    }
    return TransitionToImage(
      image:AdvancedNetworkImage(
        imageUrl,
        useDiskCache: true,
        fallbackAssetImage: "assets/imgs/cant_load.png",
        loadFailedCallback: (){
          return;
        }
      ),
      fit: fit,
      loadingWidget: placeholder ?? Container(),
      alignment: alignment,      
    );
  }
}
