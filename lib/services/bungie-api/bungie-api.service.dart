import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bungie_api/helpers/http.dart';
import 'package:bungie_api/api/destiny2.dart';
import 'package:bungie_api/responses/destiny_manifest_response.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:uni_links/uni_links.dart';

class BungieApiService{
  static const String ApiKey = '5d543dcf638a48b9a89f829f8a2373c6';
  static const String BaseUrl = 'https://www.bungie.net';
  static const String ApiUrl = "$BaseUrl/Platform";
  static const String ClientId = "23381";
  static const String ClientSecret = "lfx5V-1zoQrE..22d7rDbWXLqdHZfQXFuy544tSOgDA";
  Client client = new Client();
  
  Future<DestinyManifestResponse> getManifest(){
    return Destiny2.getDestinyManifest(this.client);
  }

  Future login() async{
    String currentLanguage = AppTranslations.currentLanguage;
    String url = "$BaseUrl/$currentLanguage/Oauth/Authorize?client_id=$ClientId&response_type=code&reauth=true";
    InAppBrowser fallback = new InAppBrowser();
    ChromeSafariBrowser browser = new ChromeSafariBrowser(fallback);
    fallback.open(url:url);
    Stream<String> _stream = getLinksStream();
    await for(var link in _stream){
      print(link);
    }
    print('launched webview');
  }
}
class Client implements HttpClient{
  
  @override
    Future<dynamic> request(HttpClientConfig config) {
      Future<http.Response> request;
      if(config.method == 'GET'){
        request = http.get("${BungieApiService.ApiUrl}${config.url}", headers: {'X-API-Key': BungieApiService.ApiKey});
      }else{
        request = http.post("${BungieApiService.ApiUrl}${config.url}", headers: {'X-API-Key': BungieApiService.ApiKey});
      }
      return request.then((response) {
        dynamic json = jsonDecode(response.body);
        return json;
      });
    }
}

class BungieAuthBrowser extends InAppBrowser{

}