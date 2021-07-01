import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:chillyflix/Models/models.dart';
import 'package:chillyflix/Services/api.dart';
import 'package:chillyflix/Services/next_up.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:chillyflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Episodes extends StatefulWidget {
  final Season season;
  Episodes(this.season);

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
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData) {
              return _buildEpisodesList(snapshot.data!);
            } else {
              return Center(child: Text(snapshot.error.toString()));
            }
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildEpisodesList(List<Episode> episodes) {
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
            },
          );
        },
      ),
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
        // REMOVED DUE TO SLOW PERFORMANCE
        /*
        if (episode.imageUris?.backdrop != null)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: episode.imageUris!.backdrop!,
                fit: BoxFit.fitWidth,
                imageErrorBuilder: (context, error, stackTrace) => Container(),
                alignment: Alignment(0.0, 0.05),
              ),
            ),
          ),
        */
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 38),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  maxLines: 3,
                  softWrap: true,
                  style: Theme.of(context).textTheme.headline2,
                ),
                const SizedBox(height: 6),
                Text(
                  "S${season.index.toString().padLeft(2, "0")}E${episode.index.toString().padLeft(2, '0')}",
                  style: GoogleFonts.sourceSansPro(
                    color: Colors.grey.shade300,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
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
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: ScrollingText(
                    startPauseDuration: Duration(seconds: 10),
                    endPauseDuration: Duration(seconds: 10),
                    scrollDirection: Axis.vertical,
                    speed: 12,
                    child: Text(
                      episode.synopsis ?? "",
                      style: GoogleFonts.sourceSansPro(
                        color: Colors.grey.shade300,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Spacer(),
          Expanded(
            child: EpisodeSources(
              episode.seriesId,
              episode.seasonIndex,
              episode.index,
              onPlay: () => Provider.of<NextUpService>(
                context,
                listen: false,
              ).updateNextUp(
                seriesId: episode.seriesId,
                seasonId: episode.seasonIndex,
                episodeId: episode.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeSources extends StatelessWidget {
  final String seriesId;
  final int seasonIndex;
  final int episodeIndex;
  final VoidCallback? onPlay;

  const EpisodeSources(this.seriesId, this.seasonIndex, this.episodeIndex,
      {this.onPlay});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaSource>>(
      future: Provider.of<FtpbdService>(context)
          .getEpisodeSources(seriesId, seasonIndex, episodeIndex),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasData) {
              final mediaSources = snapshot.data!;
              return ListView(
                shrinkWrap: true,
                children: [
                  for (final source in mediaSources)
                    RoundedCard(
                      title: source.displayName +
                          ", " +
                          formatBytes(source.fileSize),
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
                    ),
                ],
              );
            } else {
              final error = snapshot.error;
              if (error != null && error is ServerError) {
                return buildErrorBox(
                    context, (snapshot.error as ServerError).message);
              } else {
                return buildErrorBox(
                  context,
                  snapshot.error?.toString() ?? "No sources available",
                );
              }
            }
          default:
            return Container();
        }
      },
    );
  }
}
