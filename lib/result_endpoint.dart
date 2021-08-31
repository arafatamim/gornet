import 'package:goribernetflix/models/models.dart';

abstract class ResultEndpoint {
  const ResultEndpoint();
  factory ResultEndpoint.search(String query, MediaType mediaType,
      [int? limit]) = _Search;
  factory ResultEndpoint.popular(MediaType mediaType) = _Popular;

  R where<R>({
    required R Function(String query, MediaType mediaType, [int? limit]) search,
    required R Function(
      MediaType mediaType,
    )
        popular,
  }) {
    if (this is _Search) {
      final s = this as _Search;
      return search(
        s.query,
        s.mediaType,
        s.limit,
      );
    } else {
      final p = this as _Popular;
      return popular(p.mediaType);
    }
  }
}

class _Search extends ResultEndpoint {
  final String query;
  final MediaType mediaType;
  final int? limit;
  const _Search(this.query, this.mediaType, [this.limit]);
}

class _Popular extends ResultEndpoint {
  final MediaType mediaType;
  const _Popular(
    this.mediaType,
  );
}
