package main

import (
	"github.com/go-flutter-desktop/go-flutter"
)

import "github.com/go-flutter-desktop/plugins/path_provider"
import "github.com/go-flutter-desktop/plugins/shared_preferences"


var options = []flutter.Option{
	flutter.WindowInitialDimensions(1000, 800),
	
	flutter.AddPlugin(&path_provider.PathProviderPlugin{
		VendorName:      "littlelight",
		ApplicationName: "LittleLight",
	}),
	flutter.AddPlugin(&shared_preferences.SharedPreferencesPlugin{
		VendorName:      "littlelight",
		ApplicationName: "LittleLight",
	}),
}
