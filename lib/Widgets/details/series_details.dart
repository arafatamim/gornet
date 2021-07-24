import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Services/next_up.dart';
import 'package:goribernetflix/Widgets/detail_shell.dart';
import 'package:goribernetflix/Widgets/episodes.dart';
import 'package:goribernetflix/Widgets/favorites.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:goribernetflix/Widgets/season_tab.dart';
import 'package:goribernetflix/utils.dart';
import 'package:provider/provider.dart';

class SeriesDetails extends StatelessWidget {
  final Series series;

  const SeriesDetails(this.series, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: series.title ?? "Untitled Series",
      meta: _buildMeta(context),
      genres: series.genres,
      synopsis: series.synopsis,
      imageUris: series.imageUris,
      actions: [
        FavoriteIcon(id: series.id),
      ],
      continueWidget: _buildContinueWidget(context),
      child: _buildSeasons(context),
    );
  }

  FutureBuilder<List<Season>> _buildSeasons(BuildContext context) {
    return FutureBuilder<List<Season>>(
      future: Provider.of<FtpbdService>(context).getSeasons(series.id),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData) {
              final seasons = snapshot.data!;
              final deviceSize = MediaQuery.of(context).size;

              return DefaultTabController(
                length: seasons.length,
                child: deviceSize.width > 720
                    ? _buildWideSeasons(seasons)
                    : _buildMobileSeasons(context, seasons),
              );
            } else {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  FutureBuilder<StorageFormat?> _buildContinueWidget(BuildContext context) {
    return FutureBuilder<StorageFormat?>(
      // Check if there is next up data
      future: Provider.of<NextUpService>(context).getNextUp(series.id),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const SizedBox.shrink();
          case ConnectionState.done:
            if (snapshot.data != null) {
              final item = snapshot.data!;
              return FutureBuilder<List<dynamic>>(
                future: Future.wait([
                  Provider.of<FtpbdService>(context).getSeason(
                    item.seriesId,
                    item.seasonIndex,
                  ),
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
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.done:
                      if (snapshot.data != null) {
                        final Season season = snapshot.data![0] as Season;
                        final Episode episode = snapshot.data![1] as Episode;

                        const title = "Continue watching";
                        final subtitle =
                            "S${season.index.toString().padLeft(2, "0")}"
                                    "E${episode.index.toString().padLeft(2, "0")}" +
                                (" - " + episode.name);
                        onTap() {
                          showModalBottomSheet(
                            useRootNavigator: true,
                            isDismissible: false,
                            routeSettings: const RouteSettings(name: "episode"),
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return EpisodeSheet(
                                season: season,
                                episode: episode,
                              );
                            },
                          );
                        }

                        return RoundedCard(
                          title: title,
                          subtitle: subtitle,
                          onTap: onTap,
                          leading: const Icon(FeatherIcons.play),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    default:
                      return const SizedBox.shrink();
                  }
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  List<List<Widget>> _buildMeta(BuildContext context) => [
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
        ],
        [
          if (series.cast != null && series.cast!.isNotEmpty)
            Expanded(
              child: ScrollingText(
                scrollDirection: Axis.horizontal,
                child: buildLabel(
                  "Cast: " +
                      series.cast!.take(10).map((i) => i.name).join(", "),
                ),
              ),
            ),
        ]
      ];

  Widget _buildWideSeasons(List<Season> seasons) {
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
                      DefaultTabController.of(context)?.index = index;
                    },
                  );
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildEpisodesWidget(seasons),
        ),
      ],
    );
  }

  Widget _buildMobileSeasons(BuildContext context, List<Season> seasons) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: TabBar(
            indicatorColor: Theme.of(context).colorScheme.secondary,
            isScrollable: true,
            tabs: [
              for (final season in seasons) Tab(text: "Season ${season.index}")
            ],
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: _buildEpisodesWidget(seasons),
        ),
      ],
    );
  }

  Widget _buildEpisodesWidget(
    List<Season> seasons,
  ) {
    return TabBarView(
      children: <Widget>[for (final season in seasons) Episodes(season)],
    );
  }
}
