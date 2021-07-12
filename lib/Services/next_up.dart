import 'package:goribernetflix/Models/models.dart';
import "package:dio/dio.dart";

class StorageFormat {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;

  StorageFormat({
    required final this.seriesId,
    required final this.seasonIndex,
    required final this.episodeIndex,
  });

  StorageFormat.fromJson(Map<String, dynamic> json)
      : seriesId = json["id"],
        seasonIndex = json["seasonIndex"],
        episodeIndex = json["episodeIndex"];

  Map<String, dynamic> toJson() => {
        "id": seriesId,
        "seasonIndex": seasonIndex,
        "episodeIndex": episodeIndex,
      };

  static List<StorageFormat> fromJsonArray(List<dynamic> json) =>
      json.map((e) => StorageFormat.fromJson(e)).toSet().toList();

  static List<Map<String, dynamic>> toJsonArray(List<StorageFormat> items) =>
      items.map((e) => e.toJson()).toSet().toList();

  @override
  String toString() {
    return "StorageFormat { seriesId: $seriesId; seasonIndex: $seasonIndex; episodeIndex: $episodeIndex }";
  }
}

class NextUpService {
  final Dio dio;

  NextUpService({required Dio dioClient}) : dio = dioClient;

  Future<StorageFormat?> getNextUp(String seriesId) async {
    try {
      final res = await dio.get<Map<String, dynamic>>('/user/nextup/$seriesId');
      return StorageFormat.fromJson(res.data?["payload"]);
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<void> createNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
  }) async {
    try {
      await dio.post(
        '/user/nextup/create',
        data: {
          "id": seriesId,
          "seasonIndex": seasonIndex.toString(),
          "episodeIndex": episodeIndex.toString(),
        },
      );
    } on DioError catch (e) {
      throw ServerError.fromJson(e.response?.data!);
    }
  }

  Future<void> addOrUpdateNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
  }) async {
    try {
      await dio.put(
        '/user/nextup/$seriesId',
        data: {
          "seasonIndex": seasonIndex.toString(),
          "episodeIndex": episodeIndex.toString()
        },
      );
    } on DioError catch (e) {
      throw ServerError.fromJson(e.response?.data!);
    }
  }

  // Future<bool?> checkFavorite(MediaType mediaType, String id) async {
  //   try {
  //     if (await storage.ready) {
  //       await _initStorage();
  //       if (mediaType == MediaType.Movie) {
  //         final List<dynamic> data =
  //             storage.getItem("fav_movies").cast<String>();
  //         if (data.contains(id))
  //           return true;
  //         else
  //           return false;
  //       } else {
  //         final List<String> data =
  //             storage.getItem("fav_series").cast<String>();
  //         if (data.contains(id))
  //           return true;
  //         else
  //           return false;
  //       }
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // Future<void> removeNextUp(String seriesId) async {
  //   final res = await http.delete(
  //     Uri.parse('$uri/$seriesId'),
  //   );
  //   if (!res.ok) {
  //     Map<String, dynamic> decodedJson = json.decode(res.body);
  //     throw ServerError.fromJson(decodedJson);
  //   }
  // }
}
