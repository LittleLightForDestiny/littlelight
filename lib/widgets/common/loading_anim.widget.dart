import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LoadingAnimWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final enableEyeCandy = context.select<UserSettingsBloc, bool>((value) => value.enableEyeCandy);
    return Center(
        child: SizedBox(
            width: 96,
            child: Shimmer.fromColors(
              enabled: enableEyeCandy,
              baseColor: LittleLightTheme.of(context).onSurfaceLayers.layer2,
              highlightColor: LittleLightTheme.of(context).surfaceLayers.layer2,
              child: Image.asset("assets/anim/loading.webp"),
            )));
  }
}
