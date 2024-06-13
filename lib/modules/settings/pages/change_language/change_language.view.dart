import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/settings/pages/change_language/change_language.bloc.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/utils/language_names.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

class ChangeLanguageView extends StatelessWidget {
  final ChangeLanguageBloc bloc;
  final ChangeLanguageBloc state;

  const ChangeLanguageView({super.key, required this.bloc, required this.state});

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = state.selectedLanguage;
    final loaded = state.loaded;
    final canSave = state.canSave;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Change Language".translate(context, languageCode: selectedLanguage),
          key: Key("title_$selectedLanguage"),
        ),
      ),
      body: !loaded ? LoadingAnimWidget() : buildBody(context),
      bottomNavigationBar: canSave ? buildBottomBar(context) : null,
    );
  }

  Widget buildBottomBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final selectedLanguage = state.selectedLanguage;
    return Container(
      color: context.theme.secondarySurfaceLayers.layer1,
      padding: const EdgeInsets.all(8).copyWith(bottom: bottomPadding + 8),
      child: ElevatedButton(
          onPressed: () => bloc.save(),
          child: Text(
            "Change Language".translate(context, languageCode: selectedLanguage),
            key: Key("button_$selectedLanguage"),
          )),
    );
  }

  Widget buildBody(BuildContext context) {
    final languages = state.availableLanguages;
    if (languages == null) return LoadingAnimWidget();
    return SingleChildScrollView(
        padding: const EdgeInsets.all(8) +
            EdgeInsets.only(
              left: context.mediaQuery.padding.left,
              right: context.mediaQuery.padding.right,
            ),
        child: Column(children: languages.map((l) => buildLanguageItem(context, l)).toList()));
  }

  Widget buildLanguageItem(BuildContext context, String language) {
    final currentLanguage = state.currentLanguage;
    final selectedLanguage = state.selectedLanguage;
    var color = context.theme.secondarySurfaceLayers.layer0;
    if (language == currentLanguage) {
      color = context.theme.secondarySurfaceLayers.layer1;
    }
    if (language == selectedLanguage) {
      color = context.theme.primaryLayers.layer0;
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                bloc.selectedLanguage = language;
              },
              child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [buildLanguageInfo(context, language), buildFileInfo(context, language)]))),
        ));
  }

  Widget buildLanguageInfo(BuildContext context, String language) {
    final languageName = LANGUAGE_NAMES[language] ?? "";
    return Row(children: [
      const SizedBox(width: 8, height: 40),
      Container(width: 4),
      Text(
        languageName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      )
    ]);
  }

  Widget buildFileInfo(BuildContext context, String language) {
    final sizeInMb = state.getLanguageSize(language);
    final canDelete = state.canDeleteLanguage(language);
    return Row(children: [
      if (sizeInMb != null)
        Text(
          "${sizeInMb.toStringAsFixed(2)} MB",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      Container(width: sizeInMb != null ? 8 : 0),
      !canDelete
          ? Container()
          : Material(
              color: context.theme.colorScheme.error,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    bloc.delete(language);
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
