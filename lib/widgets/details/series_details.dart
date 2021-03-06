import 'package:deferred_type_flutter/deferred_type_flutter.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/services/next_up.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/widgets/detail_shell.dart';
import 'package:goribernetflix/widgets/episodes.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/buttons/favorite_button.dart';
import 'package:goribernetflix/widgets/label.dart';
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';
import 'package:goribernetflix/widgets/tabs/gn_tab_bar.dart';
import 'package:goribernetflix/widgets/wide_tile.dart';
import 'package:provider/provider.dart';

class SeriesDetails extends StatelessWidget {
  final Series series;

  const SeriesDetails(
    this.series, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: series.title ?? "Untitled Series",
      meta: _buildMeta(context),
      subtitle: series.genres?.join(", "),
      description: series.synopsis,
      imageUris: series.imageUris,
      actions: [
        FavoriteButton(seriesId: series.id),
      ],
      bottomWidget: _buildContinueWidget(context),
      child: _buildSeasons(context),
    );
  }

  Widget _buildSeasons(BuildContext context) {
    return FutureBuilder2<List<Season>>(
      future: Provider.of<FtpbdService>(context).getSeasons(series.id),
      builder: (context, result) => result.when(
        inProgress: () => const Center(child: CircularProgressIndicator()),
        idle: () => const SizedBox.shrink(),
        error: (error, _) => Center(child: ErrorMessage(error)),
        success: (data) {
          final seasons = data;
          final deviceSize = MediaQuery.of(context).size;

          return DefaultTabController(
            length: seasons.length,
            child: deviceSize.width > 720
                ? _buildWideSeasons(seasons)
                : _buildMobileSeasons(context, seasons),
          );
        },
      ),
    );
  }

  Widget _buildContinueWidget(BuildContext context) {
    Widget buildWidget(int userId) => FutureBuilder2<StorageFormat?>(
          // Check if there is next up data
          future: Provider.of<NextUpService>(context).getNextUp(
            series.id,
            userId,
          ),
          builder: (context, result) => result.maybeWhen(
            success: (item) {
              if (item != null) {
                return FutureBuilder2<List<dynamic>>(
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
                  builder: (context, result) {
                    return result.maybeWhen<Widget>(
                      success: (data) {
                        final Season season = data[0] as Season;
                        final Episode episode = data[1] as Episode;

                        const title = "Continue watching";
                        final subtitle =
                            "S${season.index.toString().padLeft(2, "0")}E${episode.index.toString().padLeft(2, "0")} - ${episode.name}";
                        void onTap() => showModalBottomSheet(
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

                        return RoundedCard(
                          key: ValueKey(episode.id),
                          title: title,
                          subtitle: subtitle,
                          onTap: onTap,
                          /* leading: const Icon(FeatherIcons.play), */
                        );
                      },
                      inProgress: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            error: (e, stack) {
              print(e);
              print(stack);
              return ErrorMessage(e);
            },
            orElse: () => const SizedBox.shrink(),
          ),
        );

    return FutureBuilder2<User?>(
      future: Provider.of<UserService>(context).getCurrentUser(),
      builder: (context, result) => result.maybeWhen<Widget>(
        success: (user) {
          if (user != null) {
            return buildWidget(user.id);
          } else {
            return const SizedBox.shrink();
          }
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  List<List<Widget>> _buildMeta(BuildContext context) => [
        <Widget>[
          if (series.year != null)
            MetaLabel(
              series.year.toString() +
                  (series.hasEnded != null
                      ? (series.hasEnded!
                          ? (series.lastAired != null
                              ? (series.lastAired!.year == series.year
                                  ? ""
                                  : " - ${series.lastAired!.year}")
                              : " - ENDED")
                          : " - PRESENT")
                      : ""),
            ),
          if (series.criticRatings?.community != null)
            MetaLabel(
              series.criticRatings!.community!.toStringAsFixed(2),
              leading: const Icon(FeatherIcons.star),
            ),
          if (series.averageRuntime != null)
            MetaLabel(
              prettyDuration(
                series.averageRuntime!,
                tersity: DurationTersity.minute,
                abbreviated: true,
                delimiter: " ",
              ),
              leading: const Icon(FeatherIcons.clock),
            ),
          if (series.networks != null && series.networks!.isNotEmpty)
            MetaLabel(series.networks![0].name),
          if (series.ageRating != null)
            MetaLabel(series.ageRating!, hasBackground: true),
        ],
        [
          if (series.cast != null && series.cast!.isNotEmpty)
            Expanded(
              child: MetaLabel(
                series.cast!.take(10).map((i) => i.name).join(" ??? "),
                title: "Cast",
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
              height: 51,
              child: Align(
                alignment: Alignment.topCenter,
                child: GNTabBar(
                  tabs: [
                    for (final season in seasons)
                      ResponsiveButton(label: season.name)
                  ],
                ),
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
              for (final season in seasons) ...[
                Tab(text: "Season ${season.index}"),
              ]
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
