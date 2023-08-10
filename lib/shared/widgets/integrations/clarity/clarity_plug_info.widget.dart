import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/clarity/clarity_data.bloc.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_line_content.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/shared/widgets/wishlists/wishlist_badge.widget.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ClarityPlugInfoWidget extends StatelessWidget {
  final int plugHash;

  ClarityPlugInfoWidget(int this.plugHash);

  @override
  Widget build(BuildContext context) {
    final descriptionWidget = buildDescriptions(context);
    if (descriptionWidget == null && 1 == 1) return Container();
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          if (descriptionWidget != null) descriptionWidget,
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launchUrlString("https://www.d2clarity.com/"),
              child: Container(
                width: 20,
                height: 20,
                child: Image.asset('assets/imgs/clarity_logo.png'),
                padding: EdgeInsets.only(right: 4),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => launchUrlString("https://www.d2clarity.com/"),
                child: Text(
                  "Clarity Insights".translate(context),
                  style: context.textTheme.highlight.copyWith(height: 1.2, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launchUrlString("https://ko-fi.com/d2clarity"),
              child: Container(
                width: 20,
                height: 20,
                child: Image.asset('assets/imgs/ko-fi-icon.png'),
                padding: EdgeInsets.only(right: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? buildDescriptions(BuildContext context) {
    final clarityState = context.watch<ClarityDataBloc>();
    final descriptions = clarityState.getPerkDescriptions(plugHash);
    if (descriptions == null) return null;
    final descriptionWidgets = descriptions.map((d) => buildDescription(context, d)).whereType<Widget>();
    if (descriptionWidgets.isEmpty) return null;
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: descriptionWidgets.toList(),
      ),
    );
  }

  Widget? buildDescription(BuildContext context, ClarityDescription description) {
    final lines = description.linesContent;
    if (lines == null) return null;
    return Container(padding: EdgeInsets.only(bottom: 4), child: RichText(text: buildLineContents(context, lines)));
  }

  InlineSpan buildLineContents(BuildContext context, List<ClarityLineContent> lines) {
    final widgets = <InlineSpan>[];
    for (final l in lines) {
      final classNames = l.classNames;
      if (classNames != null) widgets.addAll(buildIcons(context, classNames));

      final text = buildText(context, l);
      if (text != null) widgets.add(text);
    }

    return TextSpan(children: widgets);
  }

  InlineSpan? buildText(BuildContext context, ClarityLineContent content) {
    final text = content.text;
    if (text == null) return null;
    final classNames = content.classNames;
    final bold = classNames?.contains(ClarityClassNames.Bold) ?? false;
    final link = content.link;
    final isLink = classNames?.contains(ClarityClassNames.Link) ?? false;
    TextStyle style = bold || isLink ? context.textTheme.highlight : context.textTheme.body;
    if (isLink) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    if (!isLink || link == null) return TextSpan(text: text, style: style);
    final textWidget = Text(
      text,
      style: style,
    );
    return WidgetSpan(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              child: textWidget,
              onTap: () => launchUrlString(link),
            )));
  }

  List<WidgetSpan> buildIcons(BuildContext context, List<ClarityClassNames> classNames) {
    return classNames.map((e) => buildIcon(context, e)).whereType<Widget>().map((e) => WidgetSpan(child: e)).toList();
  }

  Widget? buildIcon(BuildContext context, ClarityClassNames className) {
    final iconSize = 16.0;
    switch (className) {
      case ClarityClassNames.Pve:
        return WishlistBadgeWidget(WishlistTag.PVE, size: iconSize);
      case ClarityClassNames.Pvp:
        return WishlistBadgeWidget(WishlistTag.PVP, size: iconSize);
      case ClarityClassNames.Primary:
        return Container(
          child: Icon(
            LittleLightIcons.ammo_primary,
            size: iconSize,
            color: DestinyAmmunitionType.Primary.color,
          ),
          padding: EdgeInsets.only(right: 8.0),
        );
      case ClarityClassNames.Special:
        return Container(
          child: Icon(
            LittleLightIcons.ammo_special,
            size: iconSize,
            color: DestinyAmmunitionType.Special.color,
          ),
          padding: EdgeInsets.only(right: 8.0),
        );
      case ClarityClassNames.Heavy:
        return Container(
          child: Icon(
            LittleLightIcons.ammo_heavy,
            size: iconSize,
            color: DestinyAmmunitionType.Heavy.color,
          ),
          padding: EdgeInsets.only(right: 8.0),
        );
      case ClarityClassNames.Solar:
        return Icon(
          LittleLightIcons.damage_solar,
          size: iconSize,
          color: DamageType.Thermal.getColorLayer(context).layer3,
        );
      case ClarityClassNames.Strand:
        return Icon(
          LittleLightIcons.damage_strand,
          size: iconSize,
          color: DamageType.Strand.getColorLayer(context).layer3,
        );
      case ClarityClassNames.Arc:
        return Icon(
          LittleLightIcons.damage_arc,
          size: iconSize,
          color: DamageType.Arc.getColorLayer(context).layer3,
        );
      case ClarityClassNames.Void:
        return Icon(
          LittleLightIcons.damage_void,
          size: iconSize,
          color: DamageType.Void.getColorLayer(context).layer3,
        );
      case ClarityClassNames.Stasis:
        return Icon(
          LittleLightIcons.damage_stasis,
          size: iconSize,
          color: DamageType.Stasis.getColorLayer(context).layer3,
        );
      case ClarityClassNames.Overload:
        return Icon(
          LittleLightIcons.overload,
          size: iconSize,
        );
      case ClarityClassNames.Barrier:
        return Icon(
          LittleLightIcons.pierce,
          size: iconSize,
        );
      case ClarityClassNames.Hunter:
        return Icon(
          LittleLightIcons.class_hunter,
          size: iconSize,
        );
      case ClarityClassNames.Titan:
        return Icon(
          LittleLightIcons.class_titan,
          size: iconSize,
        );
      case ClarityClassNames.Warlock:
        return Icon(
          LittleLightIcons.class_warlock,
          size: iconSize,
        );
      default:
        return null;
    }
  }
}
