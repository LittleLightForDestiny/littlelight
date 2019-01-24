import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:http/http.dart' as http;
class LittleLightApiService{
  static final LittleLightApiService _singleton = new LittleLightApiService._internal();
  factory LittleLightApiService() {
    return _singleton;
  }
  LittleLightApiService._internal();

  List<Loadout> _loadouts;

  Future<List<Loadout>> getLoadouts() async{
    if(_loadouts != null) return _loadouts;
  }

  Future<List<Loadout>> loadLoadouts() async{
    
  }

  _callServer(){

  }
}