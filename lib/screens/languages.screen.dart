import 'dart:io';

import 'package:flutter/material.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/services/translate/translate.service.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';

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
    currentLanguage = selectedLanguage = StorageService.getLanguage();
    languages = await ManifestService().getAvailableLanguages();
    fileSizes = new Map();
    for (var l in languages) {
      var storage = StorageService.language(l);
      var path = await storage.getPath(StorageKeys.manifestFile, dbPath: true);
      var file = File(path);
      if (await file.exists()) {
        fileSizes[l] = await file.length();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
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
      body: languages == null ? buildLoadingAnim(context) : buildBody(context),
      bottomNavigationBar: buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    if (currentLanguage == selectedLanguage) {
      return Container(height:0);
    }
    return Container(
      color: Colors.blueGrey.shade700,
      padding: EdgeInsets.all(8),
      child: RaisedButton(
          onPressed: () {
            StorageService.setLanguage(selectedLanguage);
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
    var service = TranslateService();
    var languageName = service.languageNames[languageCode];
    return Row(children: [
      Container(
          width: 40,
          height: 40,
          child: Image.asset("assets/imgs/flags/$languageCode.png")),
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
                  onTap: () async{
                    await StorageService.language(languageCode).purge();
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

  Widget buildLoadingAnim(BuildContext context) {
    return Center(
        child: Container(
            width: 96,
            child: Shimmer.fromColors(
              baseColor: Colors.blueGrey.shade300,
              highlightColor: Colors.white,
              child: Image.asset("assets/anim/loading.webp"),
            )));
  }
}
