import 'package:dio/dio.dart';
import 'package:goribernetflix/Models/user.dart';
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

  Future<User> getUser(int id) async {
    final res = await dio
        .get<Map<String, dynamic>>("/users/$id")
        .catchError((e) => throw mapToServerError(e));

    return User.fromJson(res.data?["payload"]);
  }

  Future<User?> getCurrentUser() async {
    final instance = await SharedPreferences.getInstance();
    final userId = instance.getInt("userId");
    if (userId != null) {
      return getUser(userId);
    }
  }

  Future<void> createUser(String username) async {
    dio.post("/users/create", data: {
      "username": username,
      "admin": false
    }).catchError((e) => throw mapToServerError(e));
  }
}
