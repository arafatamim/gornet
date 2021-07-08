import 'package:chillyflix/Models/models.dart';
import 'package:dio/dio.dart';

class FtpbdService {
  final Dio dio;

  FtpbdService({required Dio dioClient}) : dio = dioClient;

  /// [mediaType] must be `movie` or `series`
  Future<List<SearchResult>> search(
    String mediaType,
    String endpoint, {
    int limit = 6,
    String? query,
  }) async {
    assert(mediaType == "movie" || mediaType == "series");
    assert(endpoint == "search" || endpoint == "latest");
    assert(endpoint == "search" ? query != null : true);

    String pathname;
    if (query != null) {
      pathname = "/$mediaType/$endpoint";
    } else {
      pathname = "/$mediaType/$endpoint";
    }

    final res = await dio.get<Map<String, dynamic>>(pathname, queryParameters: {
      'limit': limit.toString(),
      'query': query,
    });

    List payload = res.data?['payload'];
    final results = payload.map((e) => SearchResult.fromJson(e)).toList();
    return results;
  }

  /// [mediaType] must be `movie` or `series`
  Future<List<SearchResult>> multiSearch({required String query}) async {
    final res =
        await dio.get<Map<String, dynamic>>("/search/multi", queryParameters: {
      'query': query,
    });

    List payload = res.data?['payload'];
    final results = payload.map((e) => SearchResult.fromJson(e)).toList();
    return results;
  }

  Future<Movie> getMovie(String id) async {
    final res = await dio.get<Map<String, dynamic>>("/movie/$id");

    Map<String, dynamic> payload = res.data?['payload'];
    return Movie.fromJson(payload);
  }

  Future<Series> getSeries(String id) async {
    final res = await dio.get<Map<String, dynamic>>("/series/$id");

    Map<String, dynamic> payload = res.data?['payload'];
    return Series.fromJson(payload);
  }

  Future<List<Season>> getSeasons(String id) async {
    final res = await dio.get<Map<String, dynamic>>("/series/$id/seasons");

    List payload = res.data?['payload'];
    return payload.map((e) => Season.fromJson(e)).toList();
  }

  Future<Season> getSeason(String seriesId, int seasonIndex) async {
    final res = await dio
        .get<Map<String, dynamic>>("/series/$seriesId/seasons/$seasonIndex");

    return Season.fromJson(res.data?["payload"]);
  }

  Future<Episode> getEpisode(
    String seriesId,
    int seasonIndex,
    int episodeIndex,
  ) async {
    final res = await dio.get<Map<String, dynamic>>(
        "/series/$seriesId/seasons/$seasonIndex/episodes/$episodeIndex");

    return Episode.fromJson(res.data?["payload"]);
  }

  Future<List<Episode>> getEpisodes(String seriesId, int seasonIndex) async {
    final res = await dio.get<Map<String, dynamic>>(
        "/series/$seriesId/seasons/$seasonIndex/episodes");

    List payload = res.data?['payload'];
    return payload.map((e) => Episode.fromJson(e)).toList();
  }

  Future<List<MediaSource>> getSources({
    required String id,
    int? seasonIndex,
    int? episodeIndex,
  }) async {
    final pathname = (seasonIndex != null && episodeIndex != null)
        ? "/series/$id/seasons/$seasonIndex/episodes/$episodeIndex/sources"
        : "/movie/$id/sources";
    final res = await dio.get<Map<String, dynamic>>(pathname);

    List payload = res.data?['payload'];
    return MediaSource.fromJsonList(payload);
  }

  Future<List<SearchResult>> getSimilar(String id, String mediaType) async {
    assert(mediaType == "movie" || mediaType == "series");

    final res = await dio.get<Map<String, dynamic>>("/$mediaType/$id/similar");

    List payload = res.data?['payload'];
    final results = payload.map((e) => SearchResult.fromJson(e)).toList();
    return results;
  }
}

class SearchModel {
  final String type;
  final String payload;
  SearchModel.fromJson(Map<String, dynamic> json)
      : type = json["type"],
        payload = json["payload"];
}

// class SearchService {
//   late final WebSocketChannel _channel;

//   Stream<SearchModel> get searchStream =>
//       _channel.stream.map((event) => SearchModel.fromJson(event));
//   WebSocketSink get searchSink => _channel.sink;

//   SearchService() {
//     try {
//       _channel = HtmlWebSocketChannel.connect("ws://0.0.0.0:1337");
//     } on WebSocketChannelException catch (e) {
//       print(e);
//     }
//   }
// }
