import 'package:flutter/material.dart';
import 'package:little_light/utils/platform_data.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:package_info/package_info.dart';

class CreditsScreen extends StatefulWidget {
  @override
  _CreditsScreenState createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  String packageVersion = "";
  String appName = "";
  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void getInfo() async {
    var info = await PackageInfo.fromPlatform();
    packageVersion = info.version;
    appName = info.appName;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
      body: new Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new AssetImage("assets/imgs/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(children: [
            Center(
                child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800,
                        border: Border(
                            bottom:
                                BorderSide(width: 4, color: Colors.blueGrey),
                            top: BorderSide(width: 4, color: Colors.blueGrey))),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: <Widget>[
                              Container(
                                  width: 96,
                                  height: 96,
                                  margin: EdgeInsets.all(8),
                                  child:
                                      Image.asset('assets/imgs/app_icon.png')),
                              Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "$appName v$packageVersion",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(height: 4),
                                  TranslatedTextWidget(
                                    "{appName} is brought to you by your fellow guardian",
                                    key: Key(appName),
                                    replace: {
                                      'appName': appName,
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top:8),
                                    child: buildTagAndPlatform("jaoryuken", 2),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: TranslatedTextWidget("Translations",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue.shade300),
                                uppercase: true),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              flagIcon('es'),
                              Container(width: 4),
                              Text("Español"),
                              Container(width: 8),
                              flagIcon('es-mx'),
                              Container(width: 4),
                              Text("Español Mexicano")
                            ],
                          ),
                          Container(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildTagAndPlatform("RaSSieL", 2),
                              Container(
                                width: 4,
                              ),
                              buildTagAndPlatform("alexfa55", 2),
                            ],
                          ),
                          Container(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              flagIcon('it'),
                              Container(width: 4),
                              Text("Italiano")
                            ],
                          ),
                          Container(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildTagAndPlatform("QUB3X#2230", 4),
                            ],
                          ),
                          Container(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              flagIcon('pl'),
                              Container(width: 4),
                              Text("Polski")
                            ],
                          ),
                          Container(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildTagAndPlatform("Nicolas2837", 2),
                            ],
                          ),
                          Container(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              flagIcon('ru'),
                              Container(width: 4),
                              Text("Русский")
                            ],
                          ),
                          Container(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              buildTagAndPlatform("Antonius#21840", 4),
                            ],
                          ),
                          Container(height: 12),
                        ]))),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                margin: screenPadding,
                child: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            )
          ])),
    );
  }

  flagIcon(String code) {
    return Container(
        width: 16,
        height: 16,
        child: Image.asset("assets/imgs/flags/$code.png"));
  }

  buildTagAndPlatform(String name, int platformType) {
    var platform = PlatformData.getPlatform(platformType);
    return Container(
        decoration: BoxDecoration(
            color: platform.color, borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(platform.iconData),
            Container(
              width: 4,
            ),
            Text(name)
          ],
        ));
  }
}
