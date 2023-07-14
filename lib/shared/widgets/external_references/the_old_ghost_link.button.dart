import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum OldGhostContentType {
  Chapter,
}

extension on OldGhostContentType {
  String get linkSegment {
    switch (this) {
      case OldGhostContentType.Chapter:
        return 'chapter';
    }
  }
}

class TheOldGhostLinkButton extends StatelessWidget {
  final OldGhostContentType contentType;
  final int hash;
  final String? name;
  const TheOldGhostLinkButton({
    Key? key,
    required this.contentType,
    required this.hash,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.theme.primaryLayers),
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64.0,
              child: Image.asset('assets/imgs/the-old-ghost-logo.png'),
            ),
          ],
        ),
      ),
      Positioned.fill(
          child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openLink(context),
        ),
      )),
    ]);
  }

  void openLink(BuildContext context) {
    final language = context.read<LanguageBloc>().currentLanguage;
    final type = contentType.linkSegment;
    final name = removeDiacritics(this.name).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final url = "https://oldghost.thetraveler.group/$language/$type/$hash/$name";
    launchUrlString(url);
  }
}
