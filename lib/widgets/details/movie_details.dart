import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/widgets/detail_shell.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/label.dart';
import 'package:goribernetflix/widgets/rounded_card.dart';
import 'package:ticker_text/ticker_text.dart';
import 'package:goribernetflix/utils.dart';
import 'package:provider/provider.dart';

class MovieDetails extends StatelessWidget {
  final Movie movie;

  const MovieDetails(
    this.movie, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DetailShell(
      title: movie.title ?? "Untitled Movie",
      meta: _buildMeta(context),
      genres: movie.genres,
      synopsis: movie.synopsis,
      imageUris: movie.imageUris,
      child: FutureBuilder2<List<MediaSource>>(
        future: Provider.of<FtpbdService>(context).getSources(id: movie.id),
        builder: (context, result) => result.where(
          onInProgress: () => const Center(
            child: CircularProgressIndicator(),
          ),
          onSuccess: (data) => _buildMovieSources(context, data),
          onError: (error, _) => Center(
            child: ErrorMessage(error),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
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
              child: ListView(children: _sourceList(sources)),
            )
          ],
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  List<Widget> _sourceList(List<MediaSource> sources) {
    return <Widget>[for (final source in sources) _buildSourceTile(source)];
  }

  Widget _buildSourceTile(MediaSource source) {
    return RoundedCard(
      title: source.displayName + ", ${formatBytes(source.fileSize)}",
      subtitle: source.fileName,
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
          }
        } on UnsupportedError {
          print("It's the web!");
        } catch (e) {
          print(e);
        }
      },
    );
  }

  List<List<Widget>> _buildMeta(BuildContext context) => [
        <Widget>[
          MetaLabel(movie.year.toString()),
          if (movie.criticRatings?.tmdb != null)
            MetaLabel(movie.criticRatings!.tmdb!.toString(),
                leading: const Icon(Icons.star)),
          MetaLabel(
            prettyDuration(
              movie.runtime,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
            ),
            leading: const Icon(FeatherIcons.clock),
          ),
          if (movie.ageRating != null)
            MetaLabel(movie.ageRating!, hasBackground: true),
        ],
        <Widget>[
          if (movie.directors != null && movie.directors!.isNotEmpty)
            MetaLabel("Directed by " + movie.directors![0]),
        ],
        [
          if (movie.studios != null && movie.studios!.isNotEmpty)
            MetaLabel("Production: " + movie.studios![0]),
          if (movie.cast != null)
            Expanded(
              child: TickerText(
                scrollDirection: Axis.horizontal,
                child: MetaLabel(
                  "Cast: " + movie.cast!.take(10).map((i) => i.name).join(", "),
                ),
              ),
            ),
        ]
      ];
}
