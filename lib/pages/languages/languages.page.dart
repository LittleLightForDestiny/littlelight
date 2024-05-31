import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/language_info.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:provider/provider.dart';

class LanguagesPage extends StatefulWidget {
  @override
  _LanguagesPageState createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  LanguageBloc get languageService => context.read<LanguageBloc>();
  List<LanguageInfo>? languages;
  String? currentLanguage;
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    loadLanguages();
  }

  void loadLanguages() async {
    currentLanguage = selectedLanguage = languageService.currentLanguage;
    languages = await languageService.getManifestSizes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Language".translate(context, languageCode: selectedLanguage),
          key: Key("title_$selectedLanguage"),
        ),
      ),
      body: languages == null ? LoadingAnimWidget() : buildBody(context),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    if (currentLanguage == selectedLanguage) {
      return Container(height: 0);
    }
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      color: context.theme.secondarySurfaceLayers.layer1,
      padding: const EdgeInsets.all(8).copyWith(bottom: bottomPadding + 8),
      child: ElevatedButton(
          onPressed: () {
            languageService.selectedLanguage = selectedLanguage;
            Phoenix.rebirth(context);
          },
          child: Text(
            "Change Language".translate(context, languageCode: selectedLanguage),
            key: Key("button_$selectedLanguage"),
          )),
    );
  }

  Widget buildBody(BuildContext context) {
    final languages = this.languages;
    if (languages == null) return LoadingAnimWidget();
    return SingleChildScrollView(
        padding: const EdgeInsets.all(8) +
            EdgeInsets.only(
              left: context.mediaQuery.padding.left,
              right: context.mediaQuery.padding.right,
            ),
        child: Column(children: languages.map((l) => buildLanguageItem(context, l)).toList()));
  }

  Widget buildLanguageItem(BuildContext context, LanguageInfo language) {
    var color = context.theme.secondarySurfaceLayers.layer0;
    if (language.code == currentLanguage) {
      color = context.theme.secondarySurfaceLayers.layer1;
    }
    if (language.code == selectedLanguage) {
      color = Colors.lightBlue.shade500;
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                selectedLanguage = language.code;
                setState(() {});
              },
              child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [buildLanguageInfo(context, language), buildFileInfo(context, language)]))),
        ));
  }

  Widget buildLanguageInfo(BuildContext context, LanguageInfo language) {
    return Row(children: [
      const SizedBox(width: 8, height: 40),
      Container(width: 4),
      Text(
        language.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )
    ]);
  }

  Widget buildFileInfo(BuildContext context, LanguageInfo language) {
    final sizeInKB = language.sizeInKB;
    final size = sizeInKB != null ? sizeInKB / 1024 : null;

    var canDelete = language.code != currentLanguage && size != null;
    return Row(children: [
      if (size != null)
        Text(
          "${size.toStringAsFixed(2)} MB",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      Container(width: size != null ? 8 : 0),
      !canDelete
          ? Container()
          : Material(
              color: context.theme.colorScheme.error,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    await languageService.deleteLanguage(language.code);
                    loadLanguages();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Delete".translate(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )))),
      Container(
        width: !canDelete ? 0 : 4,
      )
    ]);
  }
}
