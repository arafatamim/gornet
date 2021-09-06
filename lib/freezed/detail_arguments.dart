import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/person.dart';

part 'detail_arguments.freezed.dart';

@freezed
class DetailArgs with _$DetailArgs {
  const factory DetailArgs.media(SearchResult value) = MediaArgs;
  const factory DetailArgs.person(PersonResult value) = PersonArgs;
}

@freezed
class DetailType with _$DetailType {
  const factory DetailType.movie(Movie movie) = DMovie;
  const factory DetailType.series(Series series) = DSeries;
  const factory DetailType.person(Person person) = DPerson;
}
