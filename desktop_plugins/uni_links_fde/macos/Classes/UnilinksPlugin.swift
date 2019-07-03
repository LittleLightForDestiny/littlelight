// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FlutterMacOS
import Foundation

public class UniLinksPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    static private var _instance:UniLinksPlugin = UniLinksPlugin();
    var _eventSink:FlutterEventSink?;
    var initialLink:String?;
    var latestLink:String?;
    
    override init(){
        super.init();
         NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleURLEvent(_:with:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._eventSink = events;
        return nil;
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._eventSink = nil;
        return nil;
    }
    
    @objc
    private func handleURLEvent(_ event: NSAppleEventDescriptor, with replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return }
        self.latestLink = urlString;
        if(self.initialLink == nil){
            self.initialLink = self.latestLink;
        }
        guard let sink = self._eventSink else{
            return;
        }
        sink(self.latestLink);
    }

    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "uni_links/messages",
            binaryMessenger: registrar.messenger)
        
        let chargingChannel = FlutterEventChannel(
            name: "uni_links/events",
            binaryMessenger: registrar.messenger)

        chargingChannel.setStreamHandler(UniLinksPlugin._instance);
        registrar.addMethodCallDelegate(UniLinksPlugin._instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        if method == "getInitialLink" {
            result(self.initialLink);
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
