import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:goribernetflix/models/models.dart';

part "result_endpoint.freezed.dart";

@freezed
class ResultEndpoint with _$ResultEndpoint {
  factory ResultEndpoint.search(
    String query, {
    required MediaType mediaType,
    int? limit,
  }) = _Search;

  factory ResultEndpoint.similar(
    String id, {
    required MediaType mediaType,
  }) = _Similar;

  factory ResultEndpoint.multiSearch(String query) = _MultiSearch;

  factory ResultEndpoint.discover(
    MediaType mediaType, {
    List<String>? networks,
    List<String>? genres,
    List<String>? people,
  }) = _Discover;

  factory ResultEndpoint.personCredits(String personId) = _PersonCredits;
}
