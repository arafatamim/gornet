import 'package:goribernetflix/Models/models.dart';
import 'package:dio/dio.dart';

class FavoritesService {
  final Dio dio;

  FavoritesService({required Dio dioClient}) : dio = dioClient;

  Future<List<SearchResult>> getFavorites() async {
    final res = await dio.get<Map<String, dynamic>>("/user/favorites");
    return (res.data?["payload"] as List)
        .map((e) => SearchResult.fromJson(e))
        .toList();
  }

  Future<bool> checkFavorite(String id) async {
    final favorites = await this.getFavorites();
    return favorites.map((e) => e.id).contains(id);
  }

  Future<void> saveFavorite(String id) async {
    await dio.put("/user/favorites/$id");
  }

  Future<void> removeFavorite(String id) async {
    await dio.delete("/user/favorites/$id");
  }
}
