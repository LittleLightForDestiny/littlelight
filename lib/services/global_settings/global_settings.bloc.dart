class GlobalSettings {
  static GlobalSettings instance = GlobalSettings._();
  GlobalSettings._();

  String? _language;
  String? get language => _language;
}
