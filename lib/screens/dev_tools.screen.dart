import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';

class DevToolsScreen extends StatelessWidget {
  final TextEditingController _nameFieldController = new TextEditingController();
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
          title: Text("Dev Tools"),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildNameTextField(context),
                      buildReloadButton(context),
                      buildClearDataButton(context)
                    ]))));
  }

  Widget buildNameTextField(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: TextField(
          autocorrect: false,
          controller: _nameFieldController,
          decoration: InputDecoration(labelText: "membershipId"),
        ));
  }

  Widget buildReloadButton(BuildContext context){
    return RaisedButton(
      child: Text("Reload"),
      onPressed: ()async {
        // var membership = await AuthService().getMembership();
        // var json = membership.toJson();
        // var selected = membership.selectedMembership.toJson();

        // selected['membershipId'] = _nameFieldController.text;
        // json['selectedMembership'] = selected;
        // json['destinyMemberships'] = [selected];
        
        // membership = SavedMembership.fromJson(json);
        // await AuthService().saveMembership(membership, 2);
        await ProfileService().fetchProfileData();

        print(ProfileService().getCharacters());
      },
    );
  }

  Widget buildClearDataButton(BuildContext context){
    return RaisedButton(
      child: Text("Clear all"),
      onPressed: ()async {
        StorageService.language().purge();
        StorageService.membership().purge();
        StorageService.global().purge();
        StorageService.account().purge();
      },
    );
  }
}
