import 'dart:convert';

import 'package:chillyflix/Models/models.dart';
import 'package:chillyflix/Services/favorites.dart';
import 'package:http/http.dart' as http;

class FtpbdService {
  final String baseUrl = "192.168.0.100:6767";

  /// [mediaType] must be `movie` or `series`
  Future<List<SearchResult>> search(String mediaType, String endpoint,
      {int limit = 6, String? query}) async {
    assert(mediaType == "movie" || mediaType == "series");
    assert(
      endpoint == "search" || endpoint == "latest",
    );
    assert(endpoint == "search" ? query != null : true);

    String pathname;
    if (query != null) {
      pathname = "/api/$mediaType/$endpoint";
    } else {
      pathname = "/api/$mediaType/$endpoint";
    }

    final res = await http.get(Uri.http(
        baseUrl, pathname, {'limit': limit.toString(), 'query': query}));

    if (res.statusCode == 200) {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      List payload = decodedJson['payload'];
      final results = payload.map((e) => SearchResult.fromJson(e)).toList();
      return results;
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<Movie> getMovie(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/movie/$id"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      Map<String, dynamic> payload = decoded['payload'];
      return Movie.fromJson(payload);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<Series> getSeries(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/series/$id"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      Map<String, dynamic> payload = decoded['payload'];
      return Series.fromJson(payload);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<List<Season>> getSeasons(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/series/$id/seasons"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return payload.map((e) => Season.fromJson(e)).toList();
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<Season> getSeason(String seasonId) async {
    final res =
        await http.get(Uri.http(baseUrl, "/api/series/ID/seasons/$seasonId"));

    if (res.statusCode == 200) {
      Map<String, dynamic> decoded =
          json.decode(res.body) as Map<String, dynamic>;
      return Season.fromJson(decoded);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<Episode> getEpisode(String episodeId) async {
    final res = await http.get(
        Uri.http(baseUrl, "/api/series/ID/seasons/ID/episodes/$episodeId"));

    if (res.statusCode == 200) {
      Map<String, dynamic> decoded =
          json.decode(res.body) as Map<String, dynamic>;
      return Episode.fromJson(decoded);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<List<Episode>> getEpisodes(String seriesId, String seasonId) async {
    final res = await http.get(
        Uri.http(baseUrl, "/api/series/$seriesId/seasons/$seasonId/episodes"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return payload.map((e) => Episode.fromJson(e)).toList();
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<List<MediaSource>> getSources(String id) async {
    final res = await http.get(Uri.http(baseUrl, "/api/movie/$id/sources"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return MediaSource.fromJsonList(payload);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<List<Cast>> getCast(String id, String mediaType) async {
    assert(mediaType == "movie" || mediaType == "series");

    final res = await http.get(Uri.http(baseUrl, "/api/$mediaType/$id/cast"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      return Cast.fromJsonArray(payload);
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
    }
  }

  Future<List<SearchResult>> getSimilar(String id, String mediaType) async {
    assert(mediaType == "movie" || mediaType == "series");

    final res =
        await http.get(Uri.http(baseUrl, "/api/$mediaType/$id/similar"));

    if (res.statusCode == 200) {
      Map decoded = json.decode(res.body);
      List payload = decoded['payload'];
      final results = payload.map((e) => SearchResult.fromJson(e)).toList();
      return results;
    } else {
      Map<String, dynamic> decodedJson = json.decode(res.body);
      throw ServerError.fromJson(decodedJson);
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
