import 'package:meta/meta.dart';

class ImageUris {
  String? primary;
  String? backdrop;
  String? thumb;
  ImageUris({this.primary, this.backdrop, this.thumb});
  ImageUris.fromJson(Map<String, dynamic> json)
      : primary = json["primary"],
        backdrop = json["backdrop"],
        thumb = json["thumb"];

  @override
  String toString() {
    return "ImageUris { primary: $primary, backdrop: $backdrop, thumb: $thumb }";
  }
}

class CriticRatings {
  int? rottenTomatoes;
  double? community;
  CriticRatings({this.community, this.rottenTomatoes});
  CriticRatings.fromJson(Map<String, dynamic> json)
      : rottenTomatoes = json["rottenTomatoes"],
        community = json["community"];
}

class MediaSource {
  String streamUri;
  int bitrate;
  int fileSize;
  String fileName;
  String displayName;
  MediaSource(
      {required this.bitrate,
      required this.displayName,
      required this.fileName,
      required this.fileSize,
      required this.streamUri});
  MediaSource.fromJson(Map<String, dynamic> json)
      : bitrate = json["bitrate"],
        displayName = json["displayName"],
        fileName = json["fileName"],
        fileSize = json["fileSize"],
        streamUri = json["streamUri"];
}

class Media {
  final String id;
  final String? title;
  final int? year;
  final List<String>? genres;
  final String? ageRating;
  final String? synopsis;
  final ImageUris? imageUris;
  Media(
      {required this.id,
      this.title,
      this.year,
      this.genres,
      this.ageRating,
      this.synopsis,
      this.imageUris});

  @override
  String toString() {
    return "Media { id: $id, title: $title, year: $year, genres: $genres, ageRating: $ageRating }";
  }
}

@immutable
class Movie extends Media {
  final Duration runtime;
  final List<MediaSource> mediaSources;
  final CriticRatings? criticRatings;

  // static List<MediaSource> getSources(List<dynamic> data) {
  //   final re = data.map((e) => MediaSource.fromJson(e)).toList();
  //   print(re);
  //   // print(js);
  //   return [];
  // }

  Movie.fromJson(Map<String, dynamic> payload)
      : runtime = Duration(milliseconds: payload["runtime"].toInt()),
        mediaSources = List<Map<String, dynamic>>.from(payload["mediaSources"])
            .map((e) => MediaSource.fromJson(e))
            .toList(),
        criticRatings = CriticRatings.fromJson(payload["criticRatings"]),
        super(
            id: payload["id"],
            title: payload["title"],
            year: payload["year"],
            genres: List<String>.from(payload["genres"]),
            ageRating: payload["ageRating"],
            synopsis: payload["synopsis"],
            imageUris: ImageUris.fromJson(payload["imageUris"]));
}

@immutable
class Series extends Media {
  late final Duration? averageRuntime;
  late final bool? hasEnded;
  late final DateTime? endDate;
  late final CriticRatings? criticRatings;

  Series.fromJson(Map<String, dynamic> payload)
      : averageRuntime = payload["averageRuntime"] != null
            ? Duration(milliseconds: payload["averageRuntime"].toInt())
            : null,
        hasEnded = payload["hasEnded"],
        endDate = payload["endDate"] != null
            ? DateTime.parse(payload["endDate"])
            : null,
        criticRatings = CriticRatings.fromJson(payload["criticRatings"]),
        super(
            id: payload["id"],
            ageRating: payload["ageRating"],
            title: payload["title"],
            year: payload["year"],
            genres: List.from(payload["genres"]),
            imageUris: ImageUris.fromJson(payload["imageUris"]),
            synopsis: payload["synopsis"]);

  @override
  String toString() {
    return "Series { ${super.toString()} averageRuntime: $averageRuntime, hasEnded: $hasEnded, endDate: $endDate }";
  }
}

@immutable
class SearchResult {
  final String id;
  final String name;
  final int? year;
  final ImageUris? imageUris;
  final bool isMovie;

  SearchResult.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        year = json["year"],
        imageUris = ImageUris.fromJson(json["imageUris"]),
        isMovie = json["isMovie"];
}

@immutable
class Season {
  final String id;
  final String seriesId;
  final int? index;
  final String name;
  final ImageUris? imageUris;

  Season.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        seriesId = json["seriesId"],
        index = json["index"],
        name = json["name"],
        imageUris = ImageUris.fromJson(json["imageUris"]);

  @override
  String toString() {
    return "Season { id: $id, seriesId: $seriesId, index: $index, name: $name, imageUris: $imageUris }";
  }
}

@immutable
class Episode {
  final String id;
  final String seriesId;
  final String seasonId;
  final int? index;
  final String name;
  final String? synopsis;
  final Duration runtime;
  final DateTime? airDate;
  final ImageUris imageUris;
  final List<MediaSource> mediaSources;

  Episode.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        seriesId = json["seriesId"],
        seasonId = json["seasonId"],
        index = json["index"],
        name = json["name"],
        synopsis = json["synopsis"],
        runtime = Duration(milliseconds: json['runtime'].toInt()),
        airDate =
            json["airDate"] != null ? DateTime.parse(json["airDate"]) : null,
        imageUris = ImageUris.fromJson(json["imageUris"]),
        mediaSources = List<Map<String, dynamic>>.from(json["mediaSources"])
            .map((item) => MediaSource.fromJson(item))
            .toList();
}
