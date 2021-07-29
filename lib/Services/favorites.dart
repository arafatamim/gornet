import 'package:goribernetflix/Models/models.dart';
import 'package:dio/dio.dart';
import 'package:goribernetflix/utils.dart';

class FavoritesService {
  final Dio dio;

  FavoritesService({required Dio dioClient}) : dio = dioClient;

  Future<List<SearchResult>> getFavorites(int userId) async {
    final res = await dio
        .get<Map<String, dynamic>>("/users/$userId/favorites")
        .catchError((e) => throw mapToServerError(e));
    return (res.data?["payload"] as List<dynamic>)
        .map((e) => SearchResult.fromJson(e))
        .toList();
  }

  Future<bool> checkFavorite(String id, int userId) async {
    final favorites = await getFavorites(userId);
    return favorites.map((e) => e.id).contains(id);
  }

  Future<void> saveFavorite(String id, int userId) async {
    await dio
        .put("/users/$userId/favorites/$id")
        .catchError((e) => throw mapToServerError(e));
  }

  Future<void> removeFavorite(String id, int userId) async {
    await dio
        .delete("/users/$userId/favorites/$id")
        .catchError((e) => throw mapToServerError(e));
  }
}
