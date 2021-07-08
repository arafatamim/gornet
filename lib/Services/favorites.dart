import 'package:dio/dio.dart';

class FavoritesService {
  final Dio dio;

  FavoritesService({required Dio dioClient}) : dio = dioClient;

  Future<List<String>> getFavorites() async {
    final res = await dio.get<Map<String, dynamic>>("/user/favorites");
    return (res.data?["payload"] as List).cast<String>();
  }

  Future<bool> checkFavorite(String id) async {
    final favorites = await this.getFavorites();
    return favorites.contains(id);
  }

  Future<void> saveFavorite(String id) async {
    await dio.put("/user/favorites/$id");
  }

  Future<void> removeFavorite(String id) async {
    await dio.delete("/user/favorites/$id");
  }
}
