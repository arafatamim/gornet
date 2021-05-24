import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Widgets/Episodes.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/SeasonTab.dart';
import 'package:chillyflix/Widgets/detail_shell.dart';
import 'package:chillyflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailPage extends StatefulWidget {
  final SearchResult searchResult;

  DetailPage(this.searchResult);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  Future<Movie?>? movie;
  Future<Series?>? series;

  @override
  void initState() {
    super.initState();
    if (widget.searchResult.isMovie) {
      movie = FtpbdService().getMovie(widget.searchResult.id);
    } else {
      series = FtpbdService().getSeries(widget.searchResult.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      // needed for AndroidTV to be able to select
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent()
      },
      child: Scaffold(
        body: Container(
          color: Colors.black,
          child: Stack(
            children: <Widget>[
              buildBackdropImage(context),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withAlpha(230), Colors.transparent],
                  ),
                ),
                child: FutureBuilder<Series?>(
                  future: series,
                  builder: (context, seriesSnapshot) {
                    return FutureBuilder<Movie?>(
                      future: movie,
                      builder: (context, movieSnapshot) {
                        if (movieSnapshot.hasData) {
                          return _buildMovieDetails(movieSnapshot.data!);
                        } else if (seriesSnapshot.hasData) {
                          return _buildSeriesDetails(seriesSnapshot.data!);
                        } else if (movieSnapshot.hasError ||
                            seriesSnapshot.hasError) {
                          print(movieSnapshot.error);
                          print(seriesSnapshot.error);
                          return Center(
                            child: Text("Error!"),
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBackdropImage(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.searchResult.imageUris?.backdrop != null
            ? FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: widget.searchResult.imageUris!.backdrop!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Image.asset(
                "assets/theatre.jpg",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
      ],
    );
  }

  DetailShell _buildMovieDetails(Movie movie) {
    final _buildMeta = <Widget>[
      if (movie.criticRatings?.rottenTomatoes != null)
        ...buildLabel(
          "${movie.criticRatings?.rottenTomatoes.toString()}%",
          imageAsset: (movie.criticRatings?.rottenTomatoes! ?? -1) > 60
              ? "assets/fresh.png"
              : "assets/rotten.png",
        ),
      ...buildLabel(
        printDuration(
          movie.runtime,
          tersity: DurationTersity.minute,
          abbreviated: true,
          delimiter: " ",
        ),
        icon: Icons.timer,
      ),
      if (movie.ageRating != null) ...buildLabel(movie.ageRating!),
      ...buildLabel(movie.year.toString()),
    ];

    return DetailShell(
      title: movie.title ?? "Untitled Movie",
      meta: _buildMeta,
      genres: movie.genres,
      synopsis: movie.synopsis,
      child: _buildSources(movie.mediaSources),
    );
  }

  DetailShell _buildSeriesDetails(Series series) {
    final _buildMeta = <Widget>[
      if (series.criticRatings?.community != null)
        ...buildLabel(series.criticRatings!.community!.toStringAsFixed(2),
            icon: Icons.star),
      if (series.averageRuntime != null)
        ...buildLabel(
          printDuration(
            series.averageRuntime!,
            tersity: DurationTersity.minute,
            abbreviated: true,
            delimiter: " ",
          ),
          icon: Icons.timer,
        ),
      if (series.ageRating != null)
        ...buildLabel(
          series.ageRating!,
        ),
      ...buildLabel(
        series.year.toString() +
            (series.hasEnded != null
                ? (series.hasEnded! ? " | ENDED" : " - PRESENT")
                : ""),
      )
    ];

    return DetailShell(
      title: series.title ?? "Untitled Series",
      meta: _buildMeta,
      genres: series.genres,
      synopsis: series.synopsis,
      child: FutureBuilder<List<Season>>(
        future: Provider.of<FtpbdService>(context).getSeasons(series.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: const CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasData) {
                return _buildSeasons(snapshot.data!);
              } else {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
            default:
              return Container();
          }
        },
      ),
    );
  }

  Widget _buildSeasons(List<Season> seasons) {
    if (seasons.length != 0) {
      TabController _tabController = TabController(
        length: seasons.length,
        vsync: this,
      );

      return Column(
        children: [
          Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: seasons.length,
                  itemBuilder: (context, index) {
                    return SeasonTab(
                      season: seasons[index],
                      onTap: () {
                        _tabController.animateTo(index);
                      },
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                for (final season in seasons) Episodes(season)
              ],
            ),
          ),
        ],
      );
    } else
      return const Center(
        child: const CircularProgressIndicator(),
      );
  }

  Widget _buildSources(List<MediaSource> sources) {
    if (sources.length != 0) {
      return Container(
        child: Column(
          children: [
            Text(
              "Available sources",
              style: GoogleFonts.oswald(
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 6),
            Expanded(
              child: sourceList(sources),
            ),
          ],
        ),
      );
    } else
      return CircularProgressIndicator();
  }

  Widget sourceList(List<MediaSource> sources) {
    return ListView.builder(
      itemCount: sources.length,
      itemBuilder: (context, index) {
        return RoundedCard(
          title: sources[index].displayName +
              ", ${formatBytes(sources[index].fileSize)}",
          subtitle: sources[index].fileName,
          onTap: () {
            try {
              if (Platform.isAndroid) {
                final AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data: sources[index].streamUri,
                  type: "video/*",
                );
                intent.launch();
              }
            } on UnsupportedError {
              print("It's the web!");
            }
          },
        );
      },
    );
  }
}
