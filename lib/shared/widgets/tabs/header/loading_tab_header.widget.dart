import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'base_tab_header.widget.dart';

class LoadingTabHeaderWidget extends BaseTabHeaderWidget {
  @override
  Widget buildBackground(BuildContext context) {
    return Container(
      color: context.theme.surfaceLayers.layer0,
      child: const DefaultLoadingShimmer(),
    );
  }

  @override
  Widget buildProgressBar(BuildContext context) {
    return Container(
      color: context.theme.upgradeLayers.layer0,
      child: const DefaultLoadingShimmer(),
    );
  }

  @override
  Widget buildIcon(BuildContext context) {
    return const Center(
      child: DefaultLoadingShimmer(
        child: Icon(
          LittleLightIcons.destiny,
          size: 64,
        ),
      ),
    );
  }
}
