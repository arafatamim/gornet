import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Services/next_up.dart';
import 'package:goribernetflix/Widgets/Episodes.dart';
import 'package:goribernetflix/Widgets/RoundedCard.dart';
import 'package:goribernetflix/Widgets/SeasonTab.dart';
import 'package:goribernetflix/Widgets/detail_shell.dart';
import 'package:goribernetflix/Widgets/favorites.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:goribernetflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      media = Provider.of<FtpbdService>(context, listen: false)
          .getMovie(widget.searchResult.id);
    } else {
      media = Provider.of<FtpbdService>(context, listen: false)
          .getSeries(widget.searchResult.id);
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
                        child: buildErrorBox(context, mediaSnapshot.error),
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
            ? CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 300),
                imageUrl: widget.searchResult.imageUris!.backdrop!,
                fit: BoxFit.cover,
                placeholder: (context, url) => theatreBackdrop,
                errorWidget: (context, url, error) => theatreBackdrop,
                width: double.infinity,
                height: double.infinity,
              )
            : theatreBackdrop
      ],
    );
  }

  Widget get theatreBackdrop => Image.asset(
        "assets/theatre.jpg",
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );

  DetailShell _buildMovieDetails(Movie movie) {
    final _buildMeta = [
      <Widget>[
        buildLabel(movie.year.toString()),
        if (movie.criticRatings?.tmdb != null)
          buildLabel(movie.criticRatings!.tmdb!.toString(), icon: Icons.star),
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
      ],
      <Widget>[
        if (movie.directors != null && movie.directors!.length > 0)
          buildLabel("Directed by " + movie.directors!.join(",")),
      ],
      [
        if (movie.studios != null && movie.studios!.length > 0)
          buildLabel("Production: " + movie.studios![0]),
        if (movie.cast != null)
          Expanded(
            child: ScrollingText(
              scrollDirection: Axis.horizontal,
              child: buildLabel("Cast: " +
                  movie.cast!.take(10).map((i) => i.name).join(", ")),
            ),
          ),
      ]
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
      child: FutureBuilder<List<MediaSource>>(
        future: Provider.of<FtpbdService>(context).getSources(id: movie.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data!.length > 0) {
                return _buildSources(snapshot.data!);
              } else {
                return Center(
                  child: buildErrorBox(
                      context,
                      snapshot.error != null
                          ? snapshot.error.toString()
                          : "Error while fetching sources. Contact your system administrator."),
                );
              }
            default:
              return Container();
          }
        },
      ),
    );
  }

  DetailShell _buildSeriesDetails(Series series) {
    final _buildMeta = [
      <Widget>[
        if (series.year != null)
          buildLabel(
            series.year.toString() +
                (series.hasEnded != null
                    ? (series.hasEnded!
                        ? (series.lastAired != null
                            ? (series.lastAired!.year == series.year
                                ? ""
                                : " - " + series.lastAired!.year.toString())
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
          id: widget.searchResult.id,
        )
      ],
      [
        if (series.cast != null && series.cast!.length > 0)
          Expanded(
            child: ScrollingText(
              scrollDirection: Axis.horizontal,
              child: buildLabel("Cast: " +
                  series.cast!.take(10).map((i) => i.name).join(", ")),
            ),
          ),
      ]
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
                        .getSeason(item.seriesId, item.seasonIndex),
                    Provider.of<FtpbdService>(context).getEpisode(
                      item.seriesId,
                      item.seasonIndex,
                      item.episodeIndex,
                    ),
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
                            subtitle:
                                "S${season.index.toString().padLeft(2, "0")}" +
                                    "E${episode.index.toString().padLeft(2, "0")}" +
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
      itemBuilder: (context, i) {
        return RoundedCard(
          title:
              sources[i].displayName + ", ${formatBytes(sources[i].fileSize)}",
          subtitle: sources[i].fileName,
          scrollAxis: Axis.horizontal,
          onTap: () {
            try {
              if (Platform.isAndroid) {
                final AndroidIntent intent = AndroidIntent(
                  action: 'action_view',
                  data: sources[i].streamUri,
                  type: sources[i].mimeType ?? "video/*",
                  flags: [
                    Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                    Flag.FLAG_GRANT_PREFIX_URI_PERMISSION,
                    Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
                    Flag.FLAG_GRANT_READ_URI_PERMISSION
                  ],
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
