import 'dart:async';

import 'package:async/async.dart';
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
    ).catchError((e) {
      print(e);
      throw mapToServerError(e);
    });

    if (res.data != null) {
      final codes = TraktCode.fromJson(res.data!);
      return codes;
    } else {
      throw const ServerError(message: "Codes not found");
    }
  }

  CancelableCompleter<TraktToken> fetchToken(
    TraktCode code,
  ) {
    print("Fetching token...");
    final CancelableCompleter<TraktToken> completer =
        CancelableCompleter(onCancel: () => print("Token operation canceled!"));

    if (completer.isCompleted) {
      throw const ServerError(message: "Operation is already completed!");
    }

    Future<Response<dynamic>?> request() async {
      try {
        return await dio.post<Map<String, dynamic>>(
          "/oauth/device/token",
          data: {
            "code": code.deviceCode,
            "client_id": clientId,
            "client_secret": clientSecret
          },
        );
      } on DioError catch (e) {
        return e.response;
      } on Exception catch (_) {
        rethrow;
      }
    }

    Future<void> doRequest() async {
      while (true) {
        final res = await request();
        switch (res?.statusCode) {
          case 400:
            {
              if (completer.isCanceled) {
                completer.completeError(
                    const ServerError(message: "Token canceled!"));
                break;
              } else {
                // pending
                print("Token still pending...");
                await Future.delayed(Duration(seconds: code.interval));
                continue;
              }
            }
          case 404:
            {
              completer.completeError(
                  const ServerError(message: "Invalid device code passed!"));
              break;
            }
          case 409:
            {
              completer.completeError(
                  const ServerError(message: "Code already used up!"));
              break;
            }
          case 410:
            {
              completer.completeError(
                  const ServerError(message: "Code has expired"));
              break;
            }
          case 418:
            {
              completer.completeError(
                  const ServerError(message: "User cancelled login process"));
              break;
            }
          case 429:
            {
              completer.completeError(
                  const ServerError(message: "Polling too quickly!"));
              break;
            }
          case 200:
            {
              print("Got token!");
              completer.complete(TraktToken.fromJson(res!.data!));
              break;
            }
          default:
            {
              completer.completeError(const ServerError(
                message: "Unexpected status code while polling for token!",
              ));
              break;
            }
        }
      }
    }

    doRequest();
    return completer;
  }
}
