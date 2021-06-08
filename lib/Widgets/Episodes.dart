import 'dart:io';
import 'dart:ui';

import 'package:android_intent/android_intent.dart';
import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:chillyflix/utils.dart';
import 'package:duration/duration.dart';
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
          .getEpisodes(widget.season.seriesId, widget.season.id),
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
              episodes[index].index?.toString() ?? "?",
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
                  return _buildSheet(episodes[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSheet(Episode episode) {
    return Stack(
      children: [
        // REMOVED DUE TO SLOW PERFORMANCE
        /* 
        if (episode.imageUris.primary != null)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: episode.imageUris.primary!,
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
        EpisodeDetails(episode, widget.season),
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
                if (season.index != null && episode.index != null)
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
            child: EpisodeSources(episode.id),
          ),
        ],
      ),
    );
  }
}

class EpisodeSources extends StatelessWidget {
  final String id;

  const EpisodeSources(this.id);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MediaSource>>(
      future: Provider.of<FtpbdService>(context).getSources(id),
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
                              type: "video/*",
                            );
                            intent.launch();
                          }
                        } on UnsupportedError {
                          print("It's the web!");
                        }
                      },
                    ),
                ],
              );
            } else {
              return buildError(
                snapshot.error?.toString() ?? "No sources available",
              );
            }
          default:
            return Container();
        }
      },
    );
  }
}
