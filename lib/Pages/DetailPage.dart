import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Services/favorites.dart';
import 'package:chillyflix/Services/next_up.dart';
import 'package:chillyflix/Widgets/Episodes.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/SeasonTab.dart';
import 'package:chillyflix/Widgets/detail_shell.dart';
import 'package:chillyflix/Widgets/favorites.dart';
import 'package:chillyflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailPage extends StatefulWidget {
  final SearchResult searchResult;

  DetailPage(this.searchResult);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  late final Future<Media>? media;

  @override
  void initState() {
    super.initState();
    if (widget.searchResult.isMovie) {
      media = FtpbdService().getMovie(widget.searchResult.id);
    } else {
      media = FtpbdService().getSeries(widget.searchResult.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
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
                child: FutureBuilder<Media>(
                  future: media,
                  builder: (context, mediaSnapshot) {
                    if (mediaSnapshot.hasData) {
                      if (mediaSnapshot.data! is Movie)
                        return _buildMovieDetails(
                          mediaSnapshot.data! as Movie,
                        );
                      else
                        return _buildSeriesDetails(
                          mediaSnapshot.data! as Series,
                        );
                    } else if (mediaSnapshot.hasError) {
                      print(mediaSnapshot.error);
                      return Center(
                        child: buildError(
                          mediaSnapshot.error.toString(),
                          onRefresh: () => setState(() {}),
                        ),
                      );
                    } else {
                      return const Center(
                        child: const CircularProgressIndicator(),
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
      buildLabel(movie.year.toString()),
      if (movie.criticRatings?.rottenTomatoes != null)
        buildLabel(
          "${movie.criticRatings?.rottenTomatoes.toString()}%",
          imageAsset: (movie.criticRatings?.rottenTomatoes! ?? -1) > 60
              ? "assets/fresh.png"
              : "assets/rotten.png",
        ),
      buildLabel(
        prettyDuration(
          movie.runtime,
          tersity: DurationTersity.minute,
          abbreviated: true,
          delimiter: " ",
        ),
        icon: FeatherIcons.clock,
      ),
      if (movie.ageRating != null)
        buildLabel(movie.ageRating!, hasBackground: true),
      /*
      FavoriteIcon(
        id: widget.searchResult.id,
        mediaType: MediaType.Movie,
      )*/
    ];

    return DetailShell(
      title: movie.title ?? "Untitled Movie",
      logoUrl: movie.imageUris?.logo,
      meta: _buildMeta,
      genres: movie.genres,
      synopsis: movie.synopsis,
      child: _buildSources(movie.mediaSources),
    );
  }

  DetailShell _buildSeriesDetails(Series series) {
    final _buildMeta = <Widget>[
      if (series.year != null)
        buildLabel(
          series.year.toString() +
              (series.hasEnded != null
                  ? (series.hasEnded!
                      ? (series.endDate != null
                          ? (series.endDate!.year == series.year
                              ? ""
                              : " - " + series.endDate!.year.toString())
                          : " - ENDED")
                      : " - PRESENT")
                  : ""),
        ),
      if (series.criticRatings?.community != null)
        buildLabel(
          series.criticRatings!.community!.toStringAsFixed(2),
          icon: FeatherIcons.star,
        ),
      if (series.averageRuntime != null)
        buildLabel(
          prettyDuration(
            series.averageRuntime!,
            tersity: DurationTersity.minute,
            abbreviated: true,
            delimiter: " ",
          ),
          icon: FeatherIcons.clock,
        ),
      if (series.ageRating != null)
        buildLabel(series.ageRating!, hasBackground: true),
      FavoriteIcon(
        mediaType: MediaType.Series,
        id: widget.searchResult.id,
      )
    ];

    return DetailShell(
      title: series.title ?? "Untitled Series",
      logoUrl: series.imageUris?.logo,
      meta: _buildMeta,
      genres: series.genres,
      synopsis: series.synopsis,
      continueWidget: FutureBuilder<StorageFormat?>(
        // Check if there is next up data
        future: Provider.of<NextUpService>(context).getNextUp(series.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const SizedBox.shrink();
            case ConnectionState.done:
              if (snapshot.data != null) {
                final item = snapshot.data!;
                return FutureBuilder<List>(
                  future: Future.wait([
                    Provider.of<FtpbdService>(context)
                        .getSeason(item.seriesId, item.seasonId),
                    Provider.of<FtpbdService>(context).getEpisode(
                        item.seriesId, item.seasonId, item.episodeId),
                  ]),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Center(
                          child: const CircularProgressIndicator(),
                        );
                      case ConnectionState.done:
                        if (snapshot.data != null) {
                          final Season season = snapshot.data![0];
                          final Episode episode = snapshot.data![1];
                          return RoundedCard(
                            title: "Continue watching",
                            subtitle: (season.index != null
                                    ? "S${season.index.toString().padLeft(2, "0")}"
                                    : season.name) +
                                (episode.index != null
                                    ? "E${episode.index.toString().padLeft(2, "0")}"
                                    : episode.name) +
                                (" - " + episode.name),
                            onTap: () {
                              showModalBottomSheet(
                                useRootNavigator: true,
                                isDismissible: false,
                                routeSettings:
                                    const RouteSettings(name: "episode"),
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) {
                                  return EpisodeSheet(
                                    season: season,
                                    episode: episode,
                                  );
                                },
                              );
                            },
                          );
                        } else
                          return const SizedBox.shrink();
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                );
              } else
                return const SizedBox.shrink();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
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
                height: 210,
                child: ListView.builder(
                  itemCount: seasons.length,
                  itemBuilder: (context, index) {
                    return SeasonTab(
                      season: seasons[index],
                      onTap: () {
                        _tabController.index = index;
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
              "Available sources".toUpperCase(),
              style: Theme.of(context).textTheme.headline3?.copyWith(
                    // color: Colors.white,
                    fontSize: 20.0,
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
            } catch (e) {
              print(e);
            }
          },
        );
      },
    );
  }
}
