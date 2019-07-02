// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

public class PackageInfoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/package_info",
      binaryMessenger: registrar.messenger)
    let instance = PackageInfoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    if method == "getAll" {
      result([
        "appName": Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName"),
        "packageName": Bundle.main.bundleIdentifier ?? NSNull(),
        "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "1.0",
        "buildNumber": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        ])
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
