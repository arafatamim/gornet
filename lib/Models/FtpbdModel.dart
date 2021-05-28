import 'package:meta/meta.dart';

class ImageUris {
  final String? primary;
  final String? backdrop;
  final String? thumb;
  final String? logo;
  const ImageUris({this.primary, this.backdrop, this.thumb, this.logo});
  ImageUris.fromJson(Map<String, dynamic> json)
      : primary = json["primary"],
        backdrop = json["backdrop"],
        thumb = json["thumb"],
        logo = json["logo"];

  @override
  String toString() {
    return "ImageUris { primary: $primary, backdrop: $backdrop, thumb: $thumb, logo: $logo }";
  }
}

class CriticRatings {
  final int? rottenTomatoes;
  final num? community;
  const CriticRatings({this.community, this.rottenTomatoes});
  CriticRatings.fromJson(Map<String, dynamic> json)
      : rottenTomatoes = json["rottenTomatoes"],
        community = json["community"];
}

class MediaSource {
  final String streamUri;
  final int bitrate;
  final int fileSize;
  final String fileName;
  final String displayName;
  const MediaSource(
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

  static List<MediaSource> fromJsonList(List<dynamic> payload) =>
      List<Map<String, dynamic>>.from(payload)
          .map((item) => MediaSource.fromJson(item))
          .toList();
}

class Media {
  final String id;
  final String? title;
  final int? year;
  final List<String>? genres;
  final String? ageRating;
  final String? synopsis;
  final ImageUris? imageUris;
  const Media({
    required this.id,
    this.title,
    this.year,
    this.genres,
    this.ageRating,
    this.synopsis,
    this.imageUris,
  });

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
  final Duration? averageRuntime;
  final bool? hasEnded;
  final DateTime? endDate;
  final CriticRatings? criticRatings;

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

  const SearchResult({
    required this.id,
    required this.name,
    this.year,
    this.imageUris,
    required this.isMovie,
  });

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
  final Duration? runtime;
  final DateTime? airDate;
  final ImageUris imageUris;

  Episode.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        seriesId = json["seriesId"],
        seasonId = json["seasonId"],
        index = json["index"],
        name = json["name"],
        synopsis = json["synopsis"],
        runtime = json["runtime"] != null
            ? Duration(milliseconds: json['runtime'].toInt())
            : null,
        airDate =
            json["airDate"] != null ? DateTime.parse(json["airDate"]) : null,
        imageUris = ImageUris.fromJson(json["imageUris"]);
}
