// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

public class ScreenPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "github.com/clovisnicolas/flutter_screen",
      binaryMessenger: registrar.messenger)
    let instance = ScreenPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    if method == "keepOn" {

    } else if method == "brightness" {
      
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
