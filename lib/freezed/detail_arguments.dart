import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/person.dart';

part 'detail_arguments.freezed.dart';

@freezed
class DetailArgs with _$DetailArgs {
  const factory DetailArgs.media(SearchResult value) = _MediaArgs;
  const factory DetailArgs.person(PersonResult value) = _PersonArgs;
}

@freezed
class DetailType with _$DetailType {
  const factory DetailType.movie(Movie movie) = _Movie;
  const factory DetailType.series(Series series) = _Series;
  const factory DetailType.person(Person person) = _Person;
}
