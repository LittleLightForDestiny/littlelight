import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class SetItemNicknameDialogRoute extends DialogRoute<String?> {
  SetItemNicknameDialogRoute(BuildContext context, String currentNickname)
      : super(
          context: context,
          builder: (context) =>
              SetItemNicknameDialog(context.nicknameArgument ?? ""),
          settings: RouteSettings(arguments: currentNickname),
        );
}

extension on BuildContext {
  String? get nicknameArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is String) {
      return argument;
    }
    return null;
  }
}

class SetItemNicknameDialog extends LittleLightBaseDialog {
  final TextEditingController _controller;
  SetItemNicknameDialog(String initialValue)
      : _controller = TextEditingController(text: initialValue),
        super(
          titleBuilder: (context) => TranslatedTextWidget('Set nickname'),
        );

  @override
  Widget? buildBody(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
    );
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text("Cancel".translate(context).toUpperCase()),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: Text("Save".translate(context).toUpperCase()),
          onPressed: () async {
            Navigator.of(context).pop(_controller.value.text);
          },
        ),
      ],
    );
  }
}
