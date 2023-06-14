import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/progress/pages/objectives/objectives.bloc.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';

class ObjectivesView extends StatelessWidget {
  final ObjectivesBloc bloc;
  final ObjectivesBloc state;

  const ObjectivesView(
    this.bloc,
    this.state, {
    Key? key,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            enableFeedback: false,
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          centerTitle: false,
          title: Text("Objectives".translate(context))),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final objectives = state.objectives;
    if (objectives == null) {
      return LoadingAnimWidget();
    }
    if (objectives.isEmpty) {
      return Container(
          padding: EdgeInsets.all(4),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "You aren't tracking any objectives yet. Add one from Triumphs or Pursuits.".translate(context),
                  textAlign: TextAlign.center,
                ),
              ]));
    }
    return Container();
  }
}
