import 'package:bungie_api/enums/platform_error_codes.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bungie_api.exception.g.dart';

@JsonSerializable()
class BungieApiError {
  @JsonKey(
      name: "ErrorCode",
      unknownEnumValue: PlatformErrorCodes.ProtectedInvalidEnumValue)
  PlatformErrorCodes errorCode;

  @JsonKey(name: "ErrorStatus")
  String errorStatus;

  @JsonKey(name: "error")
  String error;

  @JsonKey(name: "Message")
  String message;

  @JsonKey(name: "error_description")
  String errorDescription;

  BungieApiError(
      {this.errorCode,
      this.errorStatus,
      this.error,
      this.message,
      this.errorDescription});

  factory BungieApiError.fromJson(Map<String, dynamic> json) {
    return _$BungieApiErrorFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$BungieApiErrorToJson(this);
  }
}

class BungieApiException implements Exception {
  BungieApiError error;
  int httpStatus;
  factory BungieApiException.fromJson(dynamic json, [int httpStatus]) {
    var error = BungieApiError.fromJson(json);
    return BungieApiException._(error, httpStatus);
  }
  BungieApiException._(this.error, [this.httpStatus]);
  PlatformErrorCodes get errorCode => error?.errorCode;
  String get errorStatus => error?.errorStatus ?? error?.error;
  String get message => error?.message ?? error?.errorDescription;
  @override
  String toString() {
    if (error == null) {
      return "httpStatus - $httpStatus";
    }
    return "$errorStatus - $message";
  }
}
