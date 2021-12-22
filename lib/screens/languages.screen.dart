import 'dart:io';

import 'package:flutter/material.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

import 'package:little_light/services/storage/export.dart';
import 'package:little_light/services/language/language.service.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<String> languages;
  Map<String, int> fileSizes;
  String currentLanguage;
  String selectedLanguage;

  @override
  void initState() {
    super.initState();
    loadLanguages();
  }

  void loadLanguages() async {
    ///TODO: add getLanguage method on language service
    // currentLanguage = selectedLanguage = StorageService.getLanguage();
    languages = await ManifestService().getAvailableLanguages();
    fileSizes = new Map();
    for (var l in languages) {
      /// TODO: implement method to get language file size on language service
      // var storage = StorageService.language(l);
      // var path = await storage.getPath(StorageKeys.manifestFile, dbPath: true);
      // var file = File(path);
      // if (await file.exists()) {
      //   fileSizes[l] = await file.length();
      // }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: TranslatedTextWidget(
          "Change Language",
          language: selectedLanguage,
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
      color: Colors.blueGrey.shade700,
      padding: EdgeInsets.all(8).copyWith(bottom: bottomPadding + 8),
      child: ElevatedButton(
          onPressed: () {
            ///TODO: add setLanguage method on language service
            // StorageService.setLanguage(selectedLanguage);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => InitialScreen(),
                ));
          },
          child: TranslatedTextWidget(
            "Change Language",
            language: selectedLanguage,
            key: Key("button_$selectedLanguage"),
          )),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
            children:
                languages.map((l) => buildLanguageItem(context, l)).toList()));
  }

  Widget buildLanguageItem(BuildContext context, String languageCode) {
    var color = Colors.blueGrey.shade800;
    if (languageCode == currentLanguage) {
      color = Colors.blueGrey.shade600;
    }
    if (languageCode == selectedLanguage) {
      color = Colors.lightBlue.shade500;
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                selectedLanguage = languageCode;
                setState(() {});
              },
              child: Container(
                  padding: EdgeInsets.all(4),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildLanguageInfo(context, languageCode),
                        buildFileInfo(context, languageCode)
                      ]))),
        ));
  }

  Widget buildLanguageInfo(BuildContext context, String languageCode) {
    var service = LanguageService();
    var languageName = service.languageNames[languageCode];
    return Row(children: [
      Container(width: 8, height: 40),
      // child: Image.asset("assets/imgs/flags/$languageCode.png")),
      Container(width: 4),
      Text(
        languageName,
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ]);
  }

  Widget buildFileInfo(BuildContext context, String languageCode) {
    double size;
    if (fileSizes[languageCode] != null) {
      size = (fileSizes[languageCode] / 1048576);
    }
    var canDelete = languageCode != currentLanguage && size != null;
    return Row(children: [
      size != null
          ? Text(
              "${size.toStringAsFixed(2)} MB",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          : Container(),
      Container(width: size != null ? 8 : 0),
      !canDelete
          ? Container()
          : Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () async {
                    /// Add method to delete language from storage
                    // await StorageService.language(languageCode).purge();
                    print('purge');
                    loadLanguages();
                  },
                  child: Container(
                      padding: EdgeInsets.all(8),
                      child: TranslatedTextWidget(
                        "Delete",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )))),
      Container(
        width: !canDelete ? 0 : 4,
      )
    ]);
  }
}
