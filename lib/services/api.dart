import 'package:goribernetflix/models/models.dart';
import 'package:dio/dio.dart';
import 'package:goribernetflix/utils.dart';
import 'package:goribernetflix/result_endpoint.dart';

class FtpbdService {
  final Dio dio;

  FtpbdService({required Dio dioClient}) : dio = dioClient;

  Future<List<SearchResult>> search(ResultEndpoint endpoint) async {
    final client = endpoint
        .where<Future<Response<Map<String, dynamic>>>>(
          search: (query, mediaType, [limit]) => dio.get<Map<String, dynamic>>(
            "/${mediaType.value}/search",
            queryParameters: {
              'limit': limit.toString(),
              'query': query,
            },
          ),
          // popular: (mediaType) => dio.get(
          //   "/${mediaType.value}/popular",
          // ),
          discover: (mediaType, {genres, networks, people}) =>
              dio.get<Map<String, dynamic>>(
            "/${mediaType.value}/discover",
            queryParameters: {
              'networks': networks?.join(","),
              'genres': genres?.join(","),
              'people': people?.join(",")
            },
          ),
          multiSearch: (query) => dio.get<Map<String, dynamic>>(
            "/search/multi",
            queryParameters: {'query': query},
          ),
          similar: (id, mediaType) => dio.get<Map<String, dynamic>>(
            "/${mediaType.value}/$id/similar",
          ),
        )
        .catchError((e) => throw mapToServerError(e));

    final res = await client;
    final payload = res.data?['payload'] as List<dynamic>;
    final results = payload.map((e) => SearchResult.fromMap(e)).toList();
    return results;
  }

  Future<Movie> getMovie(String id) async {
    final res = await dio
        .get<Map<String, dynamic>>("/movie/$id")
        .catchError((e) => throw mapToServerError(e));

    Map<String, dynamic> payload = res.data?['payload'] as Map<String, dynamic>;
    return Movie.fromMap(payload);
  }

  Future<Series> getSeries(String id) async {
    final res = await dio
        .get<Map<String, dynamic>>("/series/$id")
        .catchError((e) => throw mapToServerError(e));

    Map<String, dynamic> payload = res.data?['payload'] as Map<String, dynamic>;
    return Series.fromMap(payload);
  }

  Future<List<Season>> getSeasons(String id) async {
    final res = await dio
        .get<Map<String, dynamic>>("/series/$id/seasons")
        .catchError((e) => throw mapToServerError(e));

    final payload = res.data?['payload'] as List<dynamic>;
    return payload.map((e) => Season.fromMap(e)).toList();
  }

  Future<Season> getSeason(String seriesId, int seasonIndex) async {
    final res = await dio
        .get<Map<String, dynamic>>("/series/$seriesId/seasons/$seasonIndex")
        .catchError((e) => throw mapToServerError(e));

    return Season.fromMap(res.data?["payload"] as Map<String, dynamic>);
  }

  Future<Episode> getEpisode(
    String seriesId,
    int seasonIndex,
    int episodeIndex,
  ) async {
    final res = await dio
        .get<Map<String, dynamic>>(
            "/series/$seriesId/seasons/$seasonIndex/episodes/$episodeIndex")
        .catchError((e) => throw mapToServerError(e));

    return Episode.fromMap(res.data?["payload"] as Map<String, dynamic>);
  }

  Future<List<Episode>> getEpisodes(String seriesId, int seasonIndex) async {
    final res = await dio
        .get<Map<String, dynamic>>(
            "/series/$seriesId/seasons/$seasonIndex/episodes")
        .catchError((e) => throw mapToServerError(e));

    final payload = res.data?['payload'] as List<dynamic>;
    return payload.map((e) => Episode.fromMap(e)).toList();
  }

  Future<List<MediaSource>> getSources({
    required String id,
    int? seasonIndex,
    int? episodeIndex,
  }) async {
    final pathname = (seasonIndex != null && episodeIndex != null)
        ? "/series/$id/seasons/$seasonIndex/episodes/$episodeIndex/sources"
        : "/movie/$id/sources";
    final res = await dio
        .get<Map<String, dynamic>>(pathname)
        .catchError((e) => throw mapToServerError(e));

    final payload = res.data?['payload'] as List<dynamic>;
    return MediaSource.fromMapList(payload);
  }
}

class SearchModel {
  final String type;
  final String payload;
  SearchModel.fromMap(Map<String, dynamic> json)
      : type = json["type"] as String,
        payload = json["payload"] as String;
}

// class SearchService {
//   late final WebSocketChannel _channel;

//   Stream<SearchModel> get searchStream =>
//       _channel.stream.map((event) => SearchModel.fromMap(event));
//   WebSocketSink get searchSink => _channel.sink;

//   SearchService() {
//     try {
//       _channel = HtmlWebSocketChannel.connect("ws://0.0.0.0:1337");
//     } on WebSocketChannelException catch (e) {
//       print(e);
//     }
//   }
// }
