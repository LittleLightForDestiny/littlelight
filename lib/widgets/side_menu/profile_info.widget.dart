import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/user.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

const Duration _kExpand = Duration(milliseconds: 200);

class ProfileInfoWidget extends StatefulWidget {
  final Widget? menuContent;
  const ProfileInfoWidget({this.menuContent});

  @override
  createState() {
    return ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfoWidget>
    with SingleTickerProviderStateMixin, AuthConsumer, ProfileConsumer {
  UserMembershipData? account;
  GroupUserInfoCard? membership;

  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  AnimationController? _controller;
  Animation<double>? _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller?.drive(_easeInTween);
    _isExpanded = PageStorage.of(context).readState(context) ?? false;
    if (_isExpanded) _controller?.value = 1.0;

    loadUser();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller?.forward();
      } else {
        _controller?.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
      color: context.theme.surfaceLayers,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildProfileInfo(context),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor?.value ?? 0,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && (_controller?.isDismissed ?? false);
    if (_controller == null) return Container();
    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed ? null : Container(color: context.theme.surfaceLayers, child: widget.menuContent),
    );
  }

  loadUser() async {
    UserMembershipData? membershipData = await auth.getMembershipData();
    GroupUserInfoCard? currentMembership =
        membershipData?.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == auth.currentMembershipID);
    if (!mounted) return;
    setState(() {
      account = membershipData;
      membership = currentMembership;
    });
  }

  Widget buildProfileInfo(BuildContext context) {
    return Stack(children: [
      Column(
        children: <Widget>[
          SizedBox(height: 150, child: background(context)),
          SizedBox(height: kToolbarHeight, child: profileInfo(context)),
        ],
      ),
      Positioned(left: 8, bottom: 8, width: 72, height: 72, child: profilePicture(context))
    ]);
  }

  Widget get shimmer => const DefaultLoadingShimmer();

  Widget background(BuildContext context) {
    if (account == null) {
      return shimmer;
    }
    final profileThemeName = account?.bungieNetUser?.profileThemeName;
    if (profileThemeName == null) {
      return Container(
        color: context.theme.surfaceLayers,
      );
    }

    String? url = BungieApiService.url("/img/UserThemes/$profileThemeName/mobiletheme.jpg");
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: url != null
                ? QueuedNetworkImage(
                    imageUrl: url,
                    placeholder: shimmer,
                    fit: BoxFit.cover,
                  )
                : Container()),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Colors.black26, Colors.transparent, Colors.transparent, Colors.black54],
                  stops: const [0, .2, .7, 1])),
        ),
        Positioned(bottom: 4, left: 88, right: 4, child: buildActivityInfo(context))
      ],
    );
  }

  Widget buildActivityInfo(BuildContext context) {
    final profile = context.watch<ProfileBloc>();
    final isPlaying = profile.isPlaying;
    if (!isPlaying) {
      final lastPlayed = profile.lastPlayedTime;
      if (lastPlayed == null) return Container();
      final lastPlayedTimeAgo = timeago.format(lastPlayed, allowFromNow: true);
      return Text(
        "Last played {timeago}".translate(context, replace: {'timeago': lastPlayedTimeAgo.toLowerCase()}),
        style: context.textTheme.caption,
      );
    }
    final lastPlayedCharacter = profile.lastPlayedCharacter;
    if (lastPlayedCharacter == null) return Container();
    final activities = lastPlayedCharacter.activities;
    if (activities?.currentActivityHash == 82913930) {
      return ManifestText<DestinyPlaceDefinition>(2961497387,
          textExtractor: (def) => "${def.displayProperties?.description}",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade100, fontWeight: FontWeight.bold));
    }
    final activityModeHash = activities?.currentActivityModeHash;
    final activityHash = activities?.currentActivityHash;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      activityModeHash != null
          ? ManifestText<DestinyActivityModeDefinition>(activityModeHash, style: context.textTheme.caption)
          : Container(),
      activityHash != null
          ? ManifestText<DestinyActivityDefinition>(
              activityHash,
              style: context.textTheme.highlight,
            )
          : Container(),
    ]);
  }

  Widget profilePicture(BuildContext context) {
    String? url = BungieApiService.url(account?.bungieNetUser?.profilePicturePath);

    return Container(
        decoration: BoxDecoration(
            color: LittleLightTheme.of(context).surfaceLayers.layer0,
            border: Border.all(width: 2, color: LittleLightTheme.of(context).surfaceLayers.layer3)),
        child: url == null
            ? shimmer
            : QueuedNetworkImage(
                imageUrl: url,
                placeholder: shimmer,
                fit: BoxFit.cover,
              ));
  }

  Widget profileInfo(context) {
    bool isCrossSaveAccount = membership?.membershipId == account?.primaryMembershipId;
    PlatformData? platform = isCrossSaveAccount ? PlatformData.crossPlayData : membership?.membershipType?.data;
    return Container(
        color: platform?.color,
        padding: const EdgeInsets.only(left: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Icon(platform?.icon)),
            Expanded(child: Text(membership?.displayName ?? "")),
            IconButton(
              enableFeedback: false,
              icon: Transform.rotate(angle: -(_heightFactor?.value ?? 0) * 1.5, child: const Icon(Icons.settings)),
              onPressed: _handleTap,
            )
          ],
        ));
  }
}
