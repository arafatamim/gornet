import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Models/user.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Services/next_up.dart';
import 'package:goribernetflix/Services/user.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:goribernetflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Episodes extends StatefulWidget {
  final Season season;
  const Episodes(this.season);

  @override
  _EpisodesState createState() => _EpisodesState();
}

class _EpisodesState extends State<Episodes>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Episode>>(
      future: Provider.of<FtpbdService>(context)
          .getEpisodes(widget.season.seriesId, widget.season.index),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData) {
              final episodes = snapshot.data!;
              final deviceSize = MediaQuery.of(context).size;

              if (deviceSize.width > 720) {
                return _buildWideEpisodesList(episodes);
              } else {
                return _buildMobileEpisodesList(episodes);
              }
            } else {
              return Center(child: Text(snapshot.error.toString()));
            }
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildMobileEpisodesList(List<Episode> episodes) {
    return ListView(
      children: [
        for (var index = 0; index < episodes.length; index++)
          ListTile(
            title: Text(episodes[index].name),
            subtitle: Text(episodes[index].synopsis ?? ""),
            leading: Text(episodes[index].index.toString()),
            onTap: () {
              _displaySheet(context, episodes, index);
            },
          )
      ],
    );
  }

  Widget _buildWideEpisodesList(List<Episode> episodes) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListView.builder(
        addAutomaticKeepAlives: true,
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          return RoundedCard(
            leading: Text(
              episodes[index].index.toString(),
              style: GoogleFonts.sourceSansPro(
                fontSize: 25,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            title: episodes[index].name,
            subtitle: episodes[index].synopsis,
            scrollAxis: Axis.vertical,
            style: const RoundedCardStyle(
              cardHeight: 125,
            ),
            onTap: () {
              _displaySheet(context, episodes, index);
            },
          );
        },
      ),
    );
  }

  void _displaySheet(BuildContext context, List<Episode> episodes, int index) {
    showModalBottomSheet(
      useRootNavigator: true,
      isDismissible: false,
      routeSettings: const RouteSettings(name: "episode"),
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return EpisodeSheet(
          season: widget.season,
          episode: episodes[index],
        );
      },
    );
  }
}

class EpisodeSheet extends StatelessWidget {
  const EpisodeSheet({
    Key? key,
    required this.season,
    required this.episode,
  }) : super(key: key);

  final Season season;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (episode.imageUris?.backdrop != null)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: episode.imageUris!.backdrop!,
              fit: BoxFit.cover,
              alignment: const Alignment(0.0, -.5),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            // color: Colors.white,
            gradient: LinearGradient(
              begin: FractionalOffset.centerLeft,
              end: FractionalOffset.centerRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary.withAlpha(200),
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        EpisodeDetails(episode, season),
      ],
    );
  }
}

class EpisodeDetails extends StatelessWidget {
  final Episode episode;
  final Season season;

  const EpisodeDetails(this.episode, this.season);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (deviceSize.width > 720) {
      return _buildWideDetails(context);
    } else {
      return _buildMobileDetails(context);
    }
  }

  Padding _buildMobileDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEpisodeTitle(),
            const SizedBox(height: 6),
            _buildEpisodeNumber(),
            const SizedBox(height: 15),
            _buildMeta(),
            const SizedBox(height: 15),
            _buildSynopsis(),
            const SizedBox(height: 20),
            _buildSourcesWidget()
          ],
        ),
      ),
    );
  }

  Widget _buildWideDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 38),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEpisodeTitle(),
              const SizedBox(height: 6),
              _buildEpisodeNumber(),
              const SizedBox(height: 15),
              _buildMeta(),
              const SizedBox(height: 15),
              Expanded(
                child: ScrollingText(
                  startPauseDuration: const Duration(seconds: 10),
                  endPauseDuration: const Duration(seconds: 10),
                  scrollDirection: Axis.vertical,
                  speed: 12,
                  child: _buildSynopsis(),
                ),
              )
            ],
          ),
        ),
        const Spacer(),
        Expanded(
          child: _buildSourcesWidget(),
        )
      ]),
    );
  }

  Widget _buildEpisodeTitle() {
    return Builder(
      builder: (context) => Text(
        episode.name,
        maxLines: 3,
        softWrap: true,
        style: Theme.of(context).textTheme.headline2,
      ),
    );
  }

  Text _buildEpisodeNumber() {
    return Text(
      "S${season.index.toString().padLeft(2, "0")}"
      "E${episode.index.toString().padLeft(2, '0')}",
      style: GoogleFonts.sourceSansPro(
        color: Colors.grey.shade300,
        fontSize: 25,
      ),
    );
  }

  Row _buildMeta() {
    return Row(
      children: [
        if (episode.runtime != null)
          buildLabel(
            prettyDuration(
              episode.runtime!,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
            ),
            icon: FeatherIcons.clock,
          ),
        if (episode.airDate != null)
          buildLabel(
            "Aired on ${episode.airDate!.longMonth.capitalizeFirst} ${episode.airDate!.day}, ${episode.airDate!.year}",
          ),
      ],
    );
  }

  Widget _buildSourcesWidget() {
    return Builder(
      builder: (context) => FutureBuilder<User?>(
          future: Provider.of<UserService>(context).getCurrentUser(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return buildErrorBox(snapshot.error);
                }

                final user = snapshot.data;
                return EpisodeSources(
                  episode.seriesId,
                  episode.seasonIndex,
                  episode.index,
                  onPlay: () {
                    if (user != null) {
                      Provider.of<NextUpService>(
                        context,
                        listen: false,
                      ).createNextUp(
                        seriesId: episode.seriesId,
                        seasonIndex: episode.seasonIndex,
                        episodeIndex: episode.index,
                        userId: user.id,
                      );
                    }
                  },
                );

              default:
                return const SizedBox.shrink();
            }
          }),
    );
  }

  Text _buildSynopsis() {
    return Text(
      episode.synopsis ?? "",
      style: GoogleFonts.sourceSansPro(
        color: Colors.grey.shade300,
        fontSize: 16,
      ),
    );
  }
}

class EpisodeSources extends StatelessWidget {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;
  final VoidCallback? onPlay;

  const EpisodeSources(
    this.seriesId,
    this.seasonIndex,
    this.episodeIndex, {
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaSource>>(
      future: Provider.of<FtpbdService>(context).getSources(
        id: seriesId,
        seasonIndex: seasonIndex,
        episodeIndex: episodeIndex,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData) {
              final mediaSources = snapshot.data!;
              final deviceSize = MediaQuery.of(context).size;

              if (deviceSize.width > 720) {
                return _buildWideLayout(mediaSources);
              } else {
                return _buildMobileLayout(mediaSources);
              }
            } else {
              return buildErrorBox(snapshot.error);
            }
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSourceCard(MediaSource source) {
    return RoundedCard(
      title: source.displayName + ", " + formatBytes(source.fileSize),
      subtitle: source.fileName,
      style: const RoundedCardStyle(cardHeight: null),
      scrollAxis: Axis.horizontal,
      onTap: () {
        try {
          if (Platform.isAndroid) {
            final AndroidIntent intent = AndroidIntent(
              action: 'action_view',
              data: source.streamUri,
              type: source.mimeType ?? "video/*",
              flags: [
                Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                Flag.FLAG_GRANT_PREFIX_URI_PERMISSION,
                Flag.FLAG_GRANT_WRITE_URI_PERMISSION,
                Flag.FLAG_GRANT_READ_URI_PERMISSION
              ],
            );
            intent.launch();
            onPlay?.call();
          } else {
            print("DING DING DING");
          }
        } on UnsupportedError {
          print("It's the web!");
        }
      },
    );
  }

  Widget _buildWideLayout(List<MediaSource> mediaSources) {
    return ListView(
      shrinkWrap: true,
      children: [for (final source in mediaSources) _buildSourceCard(source)],
    );
  }

  Widget _buildMobileLayout(List<MediaSource> mediaSources) {
    return Column(
      children: [for (final source in mediaSources) _buildSourceCard(source)],
    );
  }
}
