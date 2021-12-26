import 'package:little_light/widgets/common/queued_network_image.widget.dart';

setupImageCache() {
  QueuedNetworkImage.maxNrOfCacheObjects = 5000;
  QueuedNetworkImage.inBetweenCleans = new Duration(days: 30);
}
