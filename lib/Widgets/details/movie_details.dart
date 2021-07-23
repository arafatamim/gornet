import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/Models/models.dart';
import 'package:goribernetflix/Services/api.dart';
import 'package:goribernetflix/Widgets/detail_shell.dart';
import 'package:goribernetflix/Widgets/rounded_card.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:goribernetflix/utils.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatelessWidget {
  final Movie movie;

  const MovieDetails(this.movie, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: movie.title ?? "Untitled Movie",
      logoUrl: movie.imageUris?.logo,
      meta: _buildMeta(context),
      genres: movie.genres,
      synopsis: movie.synopsis,
      child: FutureBuilder<List<MediaSource>>(
        future: Provider.of<FtpbdService>(context).getSources(id: movie.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return _buildMovieSources(context, snapshot.data!);
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

  Widget _buildMovieSources(BuildContext context, List<MediaSource> sources) {
    if (sources.isNotEmpty) {
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
            const SizedBox(height: 6),
            Expanded(
              child: _sourceList(sources),
            ),
          ],
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  Widget _sourceList(List<MediaSource> sources) {
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

  List<List<Widget>> _buildMeta(BuildContext context) => [
        <Widget>[
          buildLabel(context, movie.year.toString()),
          if (movie.criticRatings?.tmdb != null)
            buildLabel(context, movie.criticRatings!.tmdb!.toString(),
                icon: Icons.star),
          buildLabel(
            context,
            prettyDuration(
              movie.runtime,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
            ),
            icon: FeatherIcons.clock,
          ),
          if (movie.ageRating != null)
            buildLabel(context, movie.ageRating!, hasBackground: true),
        ],
        <Widget>[
          if (movie.directors != null && movie.directors!.isNotEmpty)
            buildLabel(context, "Directed by " + movie.directors!.join(",")),
        ],
        [
          if (movie.studios != null && movie.studios!.isNotEmpty)
            buildLabel(context, "Production: " + movie.studios![0]),
          if (movie.cast != null)
            Expanded(
              child: ScrollingText(
                scrollDirection: Axis.horizontal,
                child: buildLabel(
                  context,
                  "Cast: " + movie.cast!.take(10).map((i) => i.name).join(", "),
                ),
              ),
            ),
        ]
      ];
}
