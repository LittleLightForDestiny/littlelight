// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Foundation

func GetDirectoryOfType(dir: FileManager.SearchPathDirectory) -> String? {
    let paths = NSSearchPathForDirectoriesInDomains(dir, .userDomainMask, true)
    return paths.first
}

public class PathProviderPlugin : NSObject, FlutterPlugin{
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "plugins.flutter.io/path_provider", binaryMessenger: registrar.messenger)
        let instance = PathProviderPlugin();
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        if method == "getTemporaryDirectory" {
           result(self.getTemporaryDirectory())
        } else if method == "getApplicationDocumentsDirectory" {
            result(self.getApplicationDocumentsDirectory())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

     func getTemporaryDirectory() -> String? {
        return GetDirectoryOfType(dir:FileManager.SearchPathDirectory.cachesDirectory)
    }

     func getApplicationDocumentsDirectory() -> String? {
        return GetDirectoryOfType(dir:FileManager.SearchPathDirectory.documentDirectory)
    }
}
