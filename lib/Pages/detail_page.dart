import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/detail_shell.dart';
import 'package:goribernetflix/Widgets/details/movie_details.dart';
import 'package:goribernetflix/Widgets/details/series_details.dart';
import 'package:flutter/material.dart';
import 'package:goribernetflix/Widgets/error.dart';
import 'package:provider/provider.dart';
import 'package:deferred_type/deferred_type.dart';

class DetailPage extends StatelessWidget {
  final SearchResult searchResult;

  const DetailPage(this.searchResult);

  Future<Media> _getMedia(BuildContext context) {
    if (searchResult.isMovie) {
      return Provider.of<FtpbdService>(context, listen: false)
          .getMovie(searchResult.id);
    } else {
      return Provider.of<FtpbdService>(context, listen: false)
          .getSeries(searchResult.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder2<Media>(
      future: _getMedia(context),
      builder: (context, result) {
        return result.where(
          onSuccess: (media) {
            if (media is Movie) {
              return MovieDetails(media);
            } else {
              return SeriesDetails(media as Series);
            }
          },
          onError: (error, stackTrace) => Center(
            child: ErrorMessage(error),
          ),
          orElse: () => DetailShell(
            title: searchResult.name,
            imageUris: searchResult.imageUris,
          ),
        );
      },
    );
  }
}
