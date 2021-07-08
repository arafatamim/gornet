import 'package:meta/meta.dart';

enum MediaType { Movie, Series }

class ServerError implements Exception {
  final String message;
  final int status;
  ServerError(this.status, this.message);
  ServerError.fromJson(Map<String, dynamic> json)
      : message = json["error"],
        status = json["status"];

  @override
  String toString() {
    return "$message";
  }
}

class ImageUris {
  final String? primary;
  final String? backdrop;
  final String? thumb;
  final String? logo;
  final String? banner;
  const ImageUris(
      {this.primary, this.backdrop, this.thumb, this.logo, this.banner});
  ImageUris.fromJson(Map<String, dynamic> json)
      : primary = json["primary"],
        backdrop = json["backdrop"],
        thumb = json["thumb"],
        logo = json["logo"],
        banner = json["banner"];

  @override
  String toString() {
    return "ImageUris { primary: $primary, backdrop: $backdrop, thumb: $thumb, logo: $logo, banner: $logo }";
  }
}

class CriticRatings {
  final int? rottenTomatoes;
  final num? community;
  final num? tmdb;
  const CriticRatings({this.community, this.rottenTomatoes, this.tmdb});
  CriticRatings.fromJson(Map<String, dynamic> json)
      : rottenTomatoes = json["rottenTomatoes"],
        community = json["community"],
        tmdb = json["tmdb"];
}

class MediaSource {
  final String streamUri;
  final int? bitrate;
  final int fileSize;
  final String fileName;
  final String displayName;
  final String? mimeType;
  const MediaSource({
    this.bitrate,
    this.mimeType,
    required this.displayName,
    required this.fileName,
    required this.fileSize,
    required this.streamUri,
  });
  MediaSource.fromJson(Map<String, dynamic> json)
      : bitrate = json["bitrate"],
        displayName = json["displayName"],
        fileName = json["fileName"],
        fileSize = json["fileSize"],
        mimeType = json["mimeType"],
        streamUri = json["streamUri"];

  static List<MediaSource> fromJsonList(List<dynamic> payload) =>
      List<Map<String, dynamic>>.from(payload)
          .map((item) => MediaSource.fromJson(item))
          .toList();
}

class Cast {
  final String name;
  final String? role;
  final ImageUris? imageUris;
  const Cast({
    required this.name,
    this.role,
    this.imageUris,
  });

  Cast.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        role = json["role"],
        imageUris = ImageUris.fromJson(json["imageUris"]);

  static List<Cast> fromJsonArray(List<dynamic> payload) =>
      List<Map<String, dynamic>>.from(payload)
          .map((item) => Cast.fromJson(item))
          .toList();
}

class Media {
  final String id;
  final String? title;
  final int? year;
  final List<String>? genres;
  final String? ageRating;
  final String? tagline;
  final String? synopsis;
  final ImageUris? imageUris;
  final List<String>? studios;
  final List<Cast>? cast;
  const Media({
    required this.id,
    this.title,
    this.year,
    this.genres,
    this.ageRating,
    this.tagline,
    this.synopsis,
    this.imageUris,
    this.studios,
    this.cast,
  });

  @override
  String toString() {
    return "Media { id: $id, title: $title, year: $year, genres: $genres, ageRating: $ageRating }";
  }
}

@immutable
class Movie extends Media {
  final List<String>? directors;
  final Duration runtime;
  final CriticRatings? criticRatings;

  // static List<MediaSource> getSources(List<dynamic> data) {
  //   final re = data.map((e) => MediaSource.fromJson(e)).toList();
  //   print(re);
  //   // print(js);
  //   return [];
  // }

  Movie.fromJson(Map<String, dynamic> payload)
      : runtime = Duration(minutes: payload["runtime"].toInt()),
        directors = payload["directors"] != null
            ? ((payload["directors"]) as List<dynamic>).cast<String>()
            : null,
        criticRatings = CriticRatings.fromJson(payload["criticRatings"]),
        super(
          id: payload["id"],
          title: payload["title"],
          year: payload["year"],
          genres: List<String>.from(payload["genres"]),
          ageRating: payload["ageRating"],
          synopsis: payload["synopsis"],
          imageUris: ImageUris.fromJson(payload["imageUris"]),
          cast: Cast.fromJsonArray(payload["cast"]),
          studios: payload["studios"] != null
              ? ((payload["studios"]) as List<dynamic>).cast<String>()
              : null,
        );
}

@immutable
class Series extends Media {
  final Duration? averageRuntime;
  final bool? hasEnded;
  final DateTime? lastAired;
  final CriticRatings? criticRatings;

  Series.fromJson(Map<String, dynamic> payload)
      : averageRuntime = payload["averageRuntime"] != null
            ? Duration(minutes: payload["averageRuntime"].toInt())
            : null,
        hasEnded = payload["hasEnded"],
        lastAired = payload["lastAired"] != null
            ? DateTime.parse(payload["lastAired"])
            : null,
        criticRatings = CriticRatings.fromJson(payload["criticRatings"]),
        super(
          id: payload["id"],
          ageRating: payload["ageRating"],
          title: payload["title"],
          year: payload["year"],
          genres: List.from(payload["genres"]),
          imageUris: ImageUris.fromJson(payload["imageUris"]),
          synopsis: payload["synopsis"],
          cast: Cast.fromJsonArray(payload["cast"]),
          studios: payload["studios"] != null
              ? (payload["studios"] as List<dynamic>).cast<String>()
              : null,
        );

  @override
  String toString() {
    return "Series { ${super.toString()} averageRuntime: $averageRuntime, hasEnded: $hasEnded, endDate: $lastAired }";
  }
}

@immutable
class SearchResult {
  final String id;
  final String name;
  final ImageUris? imageUris;
  final bool isMovie;

  const SearchResult({
    required this.id,
    required this.name,
    required this.isMovie,
    this.imageUris,
  });

  SearchResult.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        imageUris = ImageUris.fromJson(json["imageUris"]),
        isMovie = json["isMovie"];
}

@immutable
class Season {
  final String id;
  final String seriesId;
  final int index;
  final String name;
  final int childCount;
  final ImageUris? imageUris;

  Season.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        seriesId = json["seriesId"],
        index = json["index"],
        name = json["name"],
        childCount = json["childCount"],
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
  final int seasonIndex;
  final int index;
  final String name;
  final String? synopsis;
  final List<String>? directors;
  final Duration? runtime;
  final DateTime? airDate;
  final ImageUris? imageUris;

  Episode.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        seriesId = json["seriesId"],
        seasonIndex = json["seasonIndex"],
        index = json["index"],
        name = json["name"],
        synopsis = json["synopsis"],
        runtime = json["runtime"] != null
            ? Duration(milliseconds: json['runtime'].toInt())
            : null,
        directors = json["directors"] != null
            ? ((json["directors"]) as List<dynamic>).cast<String>()
            : null,
        airDate =
            json["airDate"] != null ? DateTime.parse(json["airDate"]) : null,
        imageUris = ImageUris.fromJson(json["imageUris"]);
}
