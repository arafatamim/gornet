import 'dart:io';

import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/details/movie_details.dart';
import 'package:goribernetflix/Widgets/details/series_details.dart';
import 'package:goribernetflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: Scaffold(
        floatingActionButton: coalesceException(
          () => Platform.isLinux
              ? FloatingActionButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back),
                )
              : null,
          null,
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              _buildBackdropImage(context),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: _buildGradient(context),
                ),
                child: FutureBuilder<Media>(
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
                        child: buildErrorBox(context, mediaSnapshot.error),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _buildGradient(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isWide = deviceSize.width > 720;

    return LinearGradient(
      begin: isWide ? Alignment.centerLeft : Alignment.topCenter,
      end: isWide ? Alignment.centerRight : Alignment.bottomCenter,
      colors: [Colors.black.withAlpha(230), Colors.transparent],
    );
  }

  Widget _buildBackdropImage(BuildContext context) {
    return Stack(
      children: <Widget>[
        searchResult.imageUris?.backdrop != null
            ? CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 300),
                imageUrl: searchResult.imageUris!.backdrop!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _theatreBackdrop,
                errorWidget: (context, url, error) => _theatreBackdrop,
                width: double.infinity,
                height: double.infinity,
              )
            : _theatreBackdrop
      ],
    );
  }

  Widget get _theatreBackdrop => Image.asset(
        "assets/theatre.jpg",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
}
