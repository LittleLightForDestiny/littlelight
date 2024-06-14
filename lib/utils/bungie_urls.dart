const BUNGIE_BASE_URL = 'https://www.bungie.net';
const BUNGIE_API_URL = "$BUNGIE_BASE_URL/Platform";

String? _convertParam(dynamic value) {
  if (value is String) return value;
  if (value is num) return "$value";
  if (value is List) return value.join(',');
  return null;
}

Map<String, String>? _convertQueryParams(Map<String, dynamic>? params) {
  if (params == null) return null;
  if (params.isEmpty) return null;
  final result = <String, String>{};
  for (final entry in params.entries) {
    final value = _convertParam(entry.value);
    if (value != null) result[entry.key] = value;
  }
  return result;
}

Uri buildBungieUri({String? path, Map<String, dynamic>? params}) {
  final queryParams = _convertQueryParams(params);
  return Uri(
    scheme: "https",
    host: "www.bungie.net",
    path: path,
    queryParameters: queryParams,
  );
}

Uri buildBungieApiUri({String? path, Map<String, dynamic>? params}) {
  return buildBungieUri(path: "Platform$path", params: params);
}
