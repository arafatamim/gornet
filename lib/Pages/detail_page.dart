import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/detail_shell.dart';
import 'package:goribernetflix/Widgets/details/movie_details.dart';
import 'package:goribernetflix/Widgets/details/series_details.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return FutureBuilder<Media>(
      future: _getMedia(context),
      builder: (context, mediaSnapshot) {
        if (mediaSnapshot.hasData) {
          if (mediaSnapshot.data! is Movie) {
            return MovieDetails(mediaSnapshot.data! as Movie);
          } else {
            return SeriesDetails(mediaSnapshot.data! as Series);
          }
        } else if (mediaSnapshot.hasError) {
          print(mediaSnapshot.error);
          return Center(
            child: buildErrorBox(mediaSnapshot.error),
          );
        } else {
          return DetailShell(
            title: searchResult.name,
            imageUris: searchResult.imageUris,
          );
        }
      },
    );
  }
}
