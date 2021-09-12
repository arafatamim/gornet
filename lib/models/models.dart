import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

enum MediaType {
  movie,
  series,
  episode,
}

extension MediaTypeToString on MediaType {
  String get value {
    switch (this) {
      case MediaType.movie:
        return "movie";
      case MediaType.series:
        return "series";
      case MediaType.episode:
        return "episode";
    }
  }
}

class ServerError implements Exception {
  final String message;
  final int? status;
  const ServerError({this.status, required this.message});
  ServerError.fromMap(Map<String, dynamic> json)
      : message = json["error"] as String,
        status = json["status"] as int;

  @override
  String toString() {
    return message;
  }
}

@immutable
class ImageUris {
  final String? primary;
  final String? backdrop;
  final String? thumb;
  final String? logo;
  final String? banner;
  const ImageUris({
    this.primary,
    this.backdrop,
    this.thumb,
    this.logo,
    this.banner,
  });
  ImageUris.fromMap(dynamic json)
      : primary = json["primary"] as String?,
        backdrop = json["backdrop"] as String?,
        thumb = json["thumb"] as String?,
        logo = json["logo"] as String?,
        banner = json["banner"] as String?;

  @override
  String toString() {
    return "ImageUris { primary: $primary, backdrop: $backdrop, thumb: $thumb, logo: $logo, banner: $logo }";
  }

  Map<String, dynamic> toMap() {
    return {
      'primary': primary,
      'backdrop': backdrop,
      'thumb': thumb,
      'logo': logo,
      'banner': banner,
    };
  }
}

@immutable
class CriticRatings {
  final int? rottenTomatoes;
  final num? community;
  final num? tmdb;
  const CriticRatings({this.community, this.rottenTomatoes, this.tmdb});
  CriticRatings.fromMap(Map<String, dynamic> json)
      : rottenTomatoes = json["rottenTomatoes"] as int?,
        community = json["community"] as num?,
        tmdb = json["tmdb"] as num?;
}

@immutable
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
  MediaSource.fromMap(Map<String, dynamic> json)
      : bitrate = json["bitrate"] as int?,
        displayName = json["displayName"] as String,
        fileName = json["fileName"] as String,
        fileSize = json["fileSize"] as int,
        mimeType = json["mimeType"] as String?,
        streamUri = json["streamUri"] as String;

  static List<MediaSource> fromMapList(List<dynamic> payload) =>
      List<Map<String, dynamic>>.from(payload)
          .map((item) => MediaSource.fromMap(item))
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

  Cast.fromMap(Map<String, dynamic> json)
      : name = json["name"] as String,
        role = json["role"] as String,
        imageUris = ImageUris.fromMap(
          json["imageUris"] as Map<String, dynamic>,
        );

  static List<Cast> fromMapArray(List<dynamic> payload) =>
      List<Map<String, dynamic>>.from(payload)
          .map((item) => Cast.fromMap(item))
          .toList();
}

@immutable
class Network {
  final int id;
  final String name;
  final ImageUris? imageUris;

  const Network({
    required this.id,
    required this.name,
    this.imageUris,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUris': imageUris?.toMap(),
    };
  }

  factory Network.fromMap(Map<String, dynamic> map) {
    return Network(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUris: ImageUris.fromMap(map['imageUris']),
    );
  }

  @override
  String toString() => 'Network(id: $id, name: $name, imageUris: $imageUris)';
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
  final Duration? runtime;
  final List<String>? studios;
  final CriticRatings? criticRatings;

  // static List<MediaSource> getSources(List<dynamic> data) {
  //   final re = data.map((e) => MediaSource.fromMap(e)).toList();
  //   print(re);
  //   // print(js);
  //   return [];
  // }

  Movie.fromMap(Map<String, dynamic> payload)
      : runtime = payload["runtime"] != null
            ? Duration(minutes: payload["runtime"].toInt() as int)
            : null,
        directors = payload["directors"] != null
            ? ((payload["directors"]) as List<dynamic>).cast<String>()
            : null,
        criticRatings = CriticRatings.fromMap(
            payload["criticRatings"] as Map<String, dynamic>),
        studios = payload["studios"] != null
            ? ((payload["studios"]) as List<dynamic>).cast<String>()
            : null,
        super(
          id: payload["id"] as String,
          title: payload["title"] as String,
          year: payload["year"] as int?,
          genres: List<String>.from(payload["genres"] as List<dynamic>),
          ageRating: payload["ageRating"] as String?,
          synopsis: payload["synopsis"] as String?,
          imageUris:
              ImageUris.fromMap(payload["imageUris"] as Map<String, dynamic>),
          cast: Cast.fromMapArray(payload["cast"] as List<dynamic>),
        );
}

@immutable
class Series extends Media {
  final List<Network>? networks;
  final Duration? averageRuntime;
  final bool? hasEnded;
  final DateTime? lastAired;
  final CriticRatings? criticRatings;

  Series.fromMap(Map<String, dynamic> payload)
      : averageRuntime = payload["averageRuntime"] != null
            ? Duration(minutes: payload["averageRuntime"].toInt() as int)
            : null,
        hasEnded = payload["hasEnded"] as bool?,
        lastAired = payload["lastAired"] != null
            ? DateTime.parse(payload["lastAired"] as String)
            : null,
        criticRatings = CriticRatings.fromMap(
          payload["criticRatings"] as Map<String, dynamic>,
        ),
        networks = payload["networks"] != null
            ? (payload["networks"] as List)
                .map((e) => Network.fromMap(e as Map<String, dynamic>))
                .toList()
            : null,
        super(
          id: payload["id"] as String,
          ageRating: payload["ageRating"] as String?,
          title: payload["title"] as String,
          year: payload["year"] as int?,
          genres: List.from(payload["genres"] as List<dynamic>),
          imageUris: ImageUris.fromMap(
            payload["imageUris"] as Map<String, dynamic>,
          ),
          synopsis: payload["synopsis"] as String?,
          cast: Cast.fromMapArray(payload["cast"] as List<dynamic>),
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
  final int? year;
  final bool isMovie;

  const SearchResult({
    required this.id,
    required this.name,
    required this.isMovie,
    this.imageUris,
    this.year,
  });

  SearchResult.fromMap(dynamic json)
      : id = json["id"] as String,
        name = json["name"] as String,
        year = json["year"] as int?,
        imageUris = ImageUris.fromMap(json["imageUris"]),
        isMovie = json["isMovie"] as bool;

  static List<SearchResult> fromList(List<dynamic> data) {
    return data.map((e) => SearchResult.fromMap(e)).toList();
  }
}

@immutable
class Season {
  final String id;
  final String seriesId;
  final int index;
  final String name;
  final int childCount;
  final ImageUris? imageUris;

  Season.fromMap(dynamic json)
      : id = json["id"] as String,
        seriesId = json["seriesId"] as String,
        index = json["index"] as int,
        name = json["name"] as String,
        childCount = json["childCount"] as int,
        imageUris = ImageUris.fromMap(
          json["imageUris"] as Map<String, dynamic>,
        );

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

  Episode.fromMap(dynamic json)
      : id = json["id"] as String,
        seriesId = json["seriesId"] as String,
        seasonIndex = json["seasonIndex"] as int,
        index = json["index"] as int,
        name = json["name"] as String,
        synopsis = json["synopsis"] as String?,
        runtime = json["runtime"] != null
            ? Duration(milliseconds: json['runtime'].toInt() as int)
            : null,
        directors = (json["directors"] != null &&
                (json["directors"] as List<dynamic>).isNotEmpty)
            ? ((json["directors"]) as List<dynamic>).cast<String>()
            : null,
        airDate = json["airDate"] != null
            ? DateTime.parse(json["airDate"] as String)
            : null,
        imageUris = ImageUris.fromMap(
          json["imageUris"] as Map<String, dynamic>,
        );
}
