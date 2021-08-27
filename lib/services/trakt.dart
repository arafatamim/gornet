import 'package:dio/dio.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/trakt_code.dart';
import 'package:goribernetflix/models/trakt_token.dart';
import 'package:goribernetflix/utils.dart';

class TraktService {
  final Dio dio;
  final clientId = const String.fromEnvironment('TRAKT_CLIENT_ID');
  final clientSecret = const String.fromEnvironment('TRAKT_CLIENT_SECRET');

  const TraktService({required Dio dioClient}) : dio = dioClient;

  Future<TraktCode> generateDeviceCodes() async {
    final res = await dio.post<Map<String, dynamic>>(
      "/oauth/device/code",
      data: {"client_id": clientId},
    ).catchError((e) => throw mapToServerError(e));

    if (res.data != null) {
      final codes = TraktCode.fromJson(res.data!);
      return codes;
    } else {
      throw const ServerError(message: "Codes not found");
    }
  }

  Future<TraktToken> fetchToken(TraktCode code) async {
    final request = dio.post<Map<String, dynamic>>(
      "oauth/device/token",
      data: {
        "code": code.deviceCode,
        "client_id": clientId,
        "client_secret": clientSecret
      },
    );

    while (true) {
      final res = await request;
      switch (res.statusCode) {
        case 400: // pending
          await Future.delayed(Duration(seconds: code.interval));
          continue;
        case 404:
          throw const ServerError(message: "Invalid device code passed!");
        case 409:
          throw const ServerError(message: "Code already used up!");
        case 410:
          throw const ServerError(message: "Code has expired");
        case 418:
          throw const ServerError(message: "User cancelled login process");
        case 429:
          throw const ServerError(message: "Polling too quickly!");
        case 200:
          return TraktToken.fromJson(res.data!);
      }
    }
  }
}
