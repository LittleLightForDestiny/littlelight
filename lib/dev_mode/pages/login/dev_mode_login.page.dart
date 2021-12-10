import 'package:flutter/material.dart';
import 'dev_mode_login.page_widget.dart';

class DevModeLoginPageArguments {
  final String code;
  final String error;

  DevModeLoginPageArguments({this.code, this.error});
}

class DevModeLoginPage extends MaterialPage {
  DevModeLoginPage(String code, String error)
      : super(
            arguments: DevModeLoginPageArguments(code: code, error: error),
            child: DevModeLoginPageWidget());
}
