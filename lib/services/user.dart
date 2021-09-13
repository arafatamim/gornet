import 'package:dio/dio.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/trakt_token.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final Dio dio;

  UserService({required Dio dioClient}) : dio = dioClient;

  Future<List<User>> getUsers() async {
    final res = await dio
        .get<Map<String, dynamic>>("/users")
        .catchError((e) => throw mapToServerError(e));

    final payload = res.data?["payload"] as List<dynamic>;
    final results = payload.map((e) => User.fromJson(e)).toList();

    return results;
  }

  Future<User> getUserDetails(int id) async {
    final res = await dio
        .get<Map<String, dynamic>>("/users/$id")
        .catchError((e) => throw mapToServerError(e));

    return User.fromJson(res.data?["payload"]);
  }

  Future<User?> getCurrentUser() async {
    final instance = await SharedPreferences.getInstance();
    final userId = instance.getInt("userId");
    if (userId != null) {
      return getUserDetails(userId);
    }
  }

  Future<void> setUser(int id) async {
    final instance = await SharedPreferences.getInstance();
    instance.setInt("userId", id);
  }

  Future<void> clearUser(int id) async {
    final instance = await SharedPreferences.getInstance();
    instance.remove("userId");
  }

  Future<void> createUser(String username) async {
    await dio.post("/users/create", data: {
      "username": username,
      "admin": false
    }).catchError((e) => throw mapToServerError(e));
  }

  Future<void> saveTraktToken(int userId, TraktToken token) async {
    await dio
        .post("/users/$userId/trakt/activate", data: token.toJson())
        .catchError((e) => throw mapToServerError(e));
  }

  Future<void> deleteTraktToken(int userId) async {
    await dio
        .get("/users/$userId/trakt/deactivate")
        .catchError((e) => throw mapToServerError(e));
  }

  Future<bool> isTraktActivated(int userId) async {
    final res = await dio
        .get<Map<String, dynamic>>("/users/$userId/trakt/details")
        .catchError((e) => throw mapToServerError(e));

    return res.data!["payload"]["activated"] as bool;
  }

  Future<List<SearchResult>> getTraktWatchlist(int userId) async {
    final res = await dio
        .get<Map<String, dynamic>>("/users/$userId/trakt/watchlist")
        .catchError((e) => throw mapToServerError(e));

    final payload = res.data!["payload"] as List<dynamic>;

    return SearchResult.fromList(payload);
  }

  Future<void> addToTraktHistory(
    MediaType mediaType,
    int userId, {
    required ExternalIds ids,
  }) async {
    await dio
        .post("/users/$userId/trakt/history/${mediaType.value}",
            data: ids.toMap())
        .catchError((e) => throw mapToServerError(e));
  }
}
