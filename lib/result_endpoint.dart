import 'package:goribernetflix/models/models.dart';

abstract class ResultEndpoint {
  const ResultEndpoint();
  factory ResultEndpoint.search(String query, MediaType mediaType,
      [int? limit]) = _Search;
  factory ResultEndpoint.popular(MediaType mediaType) = _Popular;
  factory ResultEndpoint.similar(String id, MediaType mediaType) = _Similar;
  factory ResultEndpoint.multiSearch(String query) = _MultiSearch;

  R where<R>({
    required R Function(String query, MediaType mediaType, [int? limit]) search,
    required R Function(MediaType mediaType) popular,
    required R Function(String id, MediaType mediaType) similar,
    required R Function(String query) multiSearch,
  }) {
    if (this is _Search) {
      final s = this as _Search;
      return search(
        s.query,
        s.mediaType,
        s.limit,
      );
    } else if (this is _Popular) {
      final p = this as _Popular;
      return popular(p.mediaType);
    } else if (this is _Similar) {
      final s = this as _Similar;
      return similar(s.id, s.mediaType);
    } else {
      final m = this as _MultiSearch;
      return multiSearch(m.query);
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

class _Popular extends ResultEndpoint {
  final MediaType mediaType;
  const _Popular(this.mediaType);
}

class _Similar extends ResultEndpoint {
  final String id;
  final MediaType mediaType;
  const _Similar(this.id, this.mediaType);
}
