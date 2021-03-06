import "package:dio/dio.dart";
import 'package:goribernetflix/utils.dart';

class StorageFormat {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;
  final String episodeName;

  StorageFormat({
    required final this.seriesId,
    required final this.seasonIndex,
    required final this.episodeIndex,
    required final this.episodeName,
  });

  StorageFormat.fromJson(Map<String, dynamic> json)
      : seriesId = json["seriesId"] as String,
        seasonIndex = json["seasonIndex"] as int,
        episodeIndex = json["episodeIndex"] as int,
        episodeName = json["episodeName"] as String;

  Map<String, dynamic> toJson() => {
        "seriesId": seriesId,
        "seasonIndex": seasonIndex,
        "episodeIndex": episodeIndex,
        "episodeName": episodeName,
      };

  static List<StorageFormat> fromJsonArray(List<Map<String, dynamic>> json) =>
      json.map((e) => StorageFormat.fromJson(e)).toSet().toList();

  static List<Map<String, dynamic>> toJsonArray(List<StorageFormat> items) =>
      items.map((e) => e.toJson()).toSet().toList();

  @override
  String toString() {
    return "StorageFormat { seriesId: $seriesId; seasonIndex: $seasonIndex; episodeIndex: $episodeIndex; episodeName: $episodeName }";
  }
}

class NextUpService {
  final Dio dio;

  NextUpService({required Dio dioClient}) : dio = dioClient;

  Future<StorageFormat?> getNextUp(String seriesId, int userId) async {
    try {
      final res = await dio
          .get<Map<String, dynamic>>('/users/$userId/nextup/$seriesId');
      return StorageFormat.fromJson(
        res.data?["payload"] as Map<String, dynamic>,
      );
    } on DioError catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      } else {
        throw mapToServerError(e);
      }
    }
  }

  Future<void> createNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
    required final int userId,
  }) async {
    await dio.post(
      '/users/$userId/nextup/create',
      data: {
        "seriesId": seriesId,
        "seasonIndex": seasonIndex.toString(),
        "episodeIndex": episodeIndex.toString(),
      },
    ).catchError((e) => throw mapToServerError(e));
  }

  Future<void> addOrUpdateNextUp({
    required final String seriesId,
    required final int seasonIndex,
    required final int episodeIndex,
    required final int userId,
  }) async {
    await dio.put(
      '/users/$userId/nextup/$seriesId',
      data: {
        "seasonIndex": seasonIndex.toString(),
        "episodeIndex": episodeIndex.toString()
      },
    ).catchError((e) => throw mapToServerError(e));
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
