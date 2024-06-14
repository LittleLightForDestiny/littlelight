import 'dart:convert';
import 'dart:io' as io;

import 'package:bungie_api/helpers/http.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/exceptions/network_error.exception.dart';
import 'package:little_light/exceptions/not_authorized.exception.dart';
import 'package:little_light/models/bungie_api.exception.dart';

import 'bungie_urls.dart';

typedef RefreshToken = Future<String?> Function();

class BungieApiHttpClient implements HttpClient {
  final String apiKey;
  final String? accessToken;
  final RefreshToken? refreshToken;
  BungieApiHttpClient(this.apiKey, {this.accessToken, this.refreshToken});

  @override
  Future<HttpResponse> request(HttpClientConfig config) async {
    try {
      final req = await _request(config, this.accessToken);
      return req;
    } on io.SocketException catch (e) {
      throw NetworkErrorException(e, url: config.url);
    } catch (e) {
      rethrow;
    }
  }

  Future<HttpResponse> _request(HttpClientConfig config, String? token) async {
    final bodyContentType = config.bodyContentType;
    final headers = {
      'X-API-Key': apiKey,
      'Accept': 'application/json',
      if (bodyContentType != null) 'Content-Type': bodyContentType,
      if (token != null) 'Authorization': "Bearer $token"
    };

    final uri = buildBungieApiUri(path: config.url, params: config.params);
    final req = await createRequest(config.method, uri, headers: headers);
    if (config.body != null) {
      final body = config.bodyContentType == 'application/json' ? jsonEncode(config.body) : config.body;
      req.write(body);
    }

    final response = await req.close().timeout(const Duration(seconds: 15));
    if (response.statusCode == io.HttpStatus.unauthorized) {
      final newToken = await refreshToken?.call();
      if (newToken == null) throw NotAuthorizedException(null);
      return _request(config, newToken);
    }

    final responseString = await decodeResponse(response);
    final responseJson = decodeJson(responseString);

    if (response.statusCode != io.HttpStatus.ok) {
      logger.error("got an error status ${response.statusCode} from API", error: responseJson ?? responseString);
      throw BungieApiException.fromJson(responseJson ?? {}, response.statusCode);
    }

    final errorCode = responseJson?["ErrorCode"] ?? 0;

    if (errorCode > 2) {
      throw BungieApiException.fromJson(json, response.statusCode);
    }

    return HttpResponse(json, response.statusCode);
  }

  Future<io.HttpClientRequest> createRequest(
    String method,
    Uri uri, {
    Map<String, String> headers = const <String, String>{},
    dynamic body,
  }) async {
    io.HttpClient client = io.HttpClient();
    final req = await (method == "GET" ? client.getUrl(uri) : client.postUrl(uri));
    for (final header in headers.entries) {
      req.headers.add(header.key, header.value);
    }
    return req;
  }

  Future<String?> decodeResponse(io.HttpClientResponse response) async {
    try {
      final stream = response.transform(const Utf8Decoder());
      String text = "";
      await for (var t in stream) {
        text += t;
      }
      return text;
    } catch (e) {
      logger.error(e);
    }
    return null;
  }

  Map<String, dynamic>? decodeJson(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return json.decode(jsonString);
    } catch (e) {
      return null;
    }
  }
}
