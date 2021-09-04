import 'package:goribernetflix/models/models.dart';

abstract class ResultEndpoint {
  const ResultEndpoint();
  factory ResultEndpoint.search(String query, MediaType mediaType,
      [int? limit]) = _Search;
  factory ResultEndpoint.similar(String id, MediaType mediaType) = _Similar;
  factory ResultEndpoint.multiSearch(String query) = _MultiSearch;
  factory ResultEndpoint.discover(
    MediaType mediaType, {
    List<String>? networks,
    List<String>? genres,
    List<String>? people,
  }) = _Discover;
  factory ResultEndpoint.personCredits(String personId) = _PersonCredits;

  R where<R>({
    required R Function(String query, MediaType mediaType, [int? limit]) search,
    required R Function(String id, MediaType mediaType) similar,
    required R Function(String query) multiSearch,
    required R Function(
      MediaType mediaType, {
      List<String>? networks,
      List<String>? genres,
      List<String>? people,
    })
        discover,
    required R Function(String personId) personCredits,
  }) {
    if (this is _Search) {
      final s = this as _Search;
      return search(
        s.query,
        s.mediaType,
        s.limit,
      );
    } else if (this is _Similar) {
      final s = this as _Similar;
      return similar(s.id, s.mediaType);
    } else if (this is _MultiSearch) {
      final m = this as _MultiSearch;
      return multiSearch(m.query);
    } else if (this is _Discover) {
      final d = this as _Discover;
      return discover(
        d.mediaType,
        genres: d.genres,
        networks: d.networks,
        people: d.people,
      );
    } else if (this is _PersonCredits) {
      final p = this as _PersonCredits;
      return personCredits(p.personId);
    } else {
      throw Exception("ResultEndpoint case out of bounds!");
    }
  }
}

class _Search extends ResultEndpoint {
  final String query;
  final MediaType mediaType;
  final int? limit;
  const _Search(this.query, this.mediaType, [this.limit]);
}

class _MultiSearch extends ResultEndpoint {
  final String query;
  const _MultiSearch(this.query);
}

class _Similar extends ResultEndpoint {
  final String id;
  final MediaType mediaType;
  const _Similar(this.id, this.mediaType);
}

class _Discover extends ResultEndpoint {
  final MediaType mediaType;
  final List<String>? networks;
  final List<String>? genres;
  final List<String>? people;
  const _Discover(
    this.mediaType, {
    this.networks,
    this.genres,
    this.people,
  });
}

class _PersonCredits extends ResultEndpoint {
  final String personId;
  const _PersonCredits(this.personId);
}
