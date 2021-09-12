import 'package:goribernetflix/freezed/detail_arguments.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/widgets/detail_shell.dart';
import 'package:goribernetflix/widgets/details/movie_details.dart';
import 'package:goribernetflix/widgets/details/person_details.dart';
import 'package:goribernetflix/widgets/details/series_details.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:provider/provider.dart';
import 'package:deferred_type/deferred_type.dart';

class DetailPage extends StatelessWidget {
  final DetailArgs args;

  const DetailPage(this.args);

  Future<DetailType> _getData(BuildContext context) {
    return args.when(
      media: (media) async {
        if (media.isMovie) {
          final movie = await Provider.of<FtpbdService>(context, listen: false)
              .getMovie(media.id);
          return DetailType.movie(movie);
        } else {
          final series = await Provider.of<FtpbdService>(context, listen: false)
              .getSeries(media.id);
          return DetailType.series(series);
        }
      },
      person: (value) async {
        final person = await Provider.of<FtpbdService>(context, listen: false)
            .getPerson(value.id);
        return DetailType.person(person);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<DetailType>(
      future: _getData(context),
      builder: (context, result) {
        return result.maybeWhen(
          success: (media) => media.when(
            movie: (movie) => MovieDetails(movie),
            series: (series) => SeriesDetails(series),
            person: (person) => PersonDetails(person),
          ),
          error: (error, stackTrace) {
            print(error);
            return Center(
              child: ErrorMessage(error),
            );
          },
          orElse: () => args.when(
            media: (media) => DetailShell(
              title: media.name,
              imageUris: media.imageUris,
            ),
            person: (person) => DetailShell(
              title: person.name,
              imageUris: person.imageUris,
            ),
          ),
        );
      },
    );
  }
}
