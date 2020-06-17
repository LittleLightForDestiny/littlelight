import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';


class DevToolsScreen extends StatelessWidget {
  final Map<String, TextEditingController> fieldControllers = Map();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(enableFeedback: false,
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: Text("Dev Tools"),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTextField(context, "membershipId"),
                      buildButton(context, "Reload", () async {
                        await ProfileService().fetchProfileData();
                        print(ProfileService().getCharacters());
                      }),
                      buildButton(
                        context,
                        "Clear Data",
                        () async {
                          StorageService.language().purge();
                          StorageService.membership().purge();
                          StorageService.global().purge();
                          StorageService.account().purge();
                        },
                      ),
                      buildDivider(context),
                      buildTextField(context, "Wishlist URL", "https://raw.githubusercontent.com/48klocs/dim-wish-list-sources/master/voltron.txt"),
                      buildButton(
                        context,
                        "Load Wishlist",
                        () async {
                          
                        },
                      ),
                    ]))));
  }

  Widget buildTextField(BuildContext context, String label, [String initialValue= ""]) {
    var controller = fieldControllers[label];
    if (controller == null) {
      controller = fieldControllers[label] = TextEditingController(text: initialValue);
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: TextField(
          autocorrect: false,
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ));
  }

  Widget buildButton(BuildContext context, String label, Function onPressed) {
    return RaisedButton(
      child: Text(label),
      onPressed: onPressed,
    );
  }

  Widget buildDivider(BuildContext context) {
    return Container(
        color: Colors.white,
        height: 1,
        margin: EdgeInsets.symmetric(vertical: 16));
  }
}
