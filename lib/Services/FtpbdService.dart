import 'dart:convert';

import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/StorageService.dart';
import 'package:http/http.dart' as http;

class FtpbdService {
  String baseUrl = "192.168.0.100:6565";

  /// [endpoint] must be `movie` or `series`
  Future<List<SearchResult>> search(String endpoint,
      {int limit = 6, String? query}) async {
    assert(endpoint == "movie" || endpoint == "series");

    String pathname;
    if (query != null) {
      pathname = "/api/v2/$endpoint/search";
    } else {
      pathname = "/api/v2/$endpoint/latest";
    }

    final res = await http.get(Uri.http(
        baseUrl, pathname, {'limit': limit.toString(), 'query': query}));

    if (res.statusCode == 200) {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      List payload = decodedJson['payload'];
      final results = payload.map((e) => SearchResult.fromJson(e)).toList();
      return results;
    } else {
      throw Exception("Invalid status code for query $endpoint, $query");
    }
  }

  Future<Movie> getMovie(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/v2/movie/$id"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      Map<String, dynamic> payload = decoded['payload'];
      return Movie.fromJson(payload);
    } else {
      throw Exception("Unhandled status when fetching movie $id");
    }
  }

  Future<Series> getSeries(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/v2/series/$id"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      Map<String, dynamic> payload = decoded['payload'];
      return Series.fromJson(payload);
    } else {
      throw Exception("Unhandled status when fetching series $id");
    }
  }

  Future<List<Season>> getSeasons(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/v2/series/$id/seasons"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return payload.map((e) => Season.fromJson(e)).toList();
    } else {
      throw Exception("Unhandled status when fetching seasons for series $id");
    }
  }

  Future<List<Episode>> getEpisodes(String seriesId, String seasonId) async {
    final res = await http.get(Uri.http(
        baseUrl, "/api/v2/series/$seriesId/seasons/$seasonId/episodes"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return payload.map((e) => Episode.fromJson(e)).toList();
    } else {
      throw Exception("Unhandled status when fetching episodes");
    }
  }

  Future<List<MediaSource>> getSources(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/v2/sources/$id"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return MediaSource.fromJsonList(payload);
    } else {
      throw Exception("Unhandled status when fetching sources");
    }
  }

  static Future<SearchResult> mapIdToSearchResult(
    MediaType mediaType,
    String id,
  ) async {
    switch (mediaType) {
      case MediaType.Movie:
        final movie = await FtpbdService().getMovie(id);
        final item = SearchResult(
          id: movie.id,
          name: movie.title ?? "",
          isMovie: true,
          imageUris: movie.imageUris,
          year: movie.year,
        );
        return item;
      case MediaType.Series:
        final series = await FtpbdService().getSeries(id);
        final item = SearchResult(
          id: series.id,
          name: series.title ?? "",
          isMovie: false,
          imageUris: series.imageUris,
          year: series.year,
        );
        return item;
    }
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
