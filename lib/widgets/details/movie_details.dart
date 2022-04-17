import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:deferred_type/deferred_type.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:goribernetflix/models/models.dart';
import 'package:goribernetflix/models/user.dart';
import 'package:goribernetflix/services/api.dart';
import 'package:goribernetflix/services/user.dart';
import 'package:goribernetflix/widgets/buttons/responsive_button.dart';
import 'package:goribernetflix/widgets/detail_shell.dart';
import 'package:goribernetflix/widgets/dialogs/responsive_dialog.dart';
import 'package:goribernetflix/widgets/error.dart';
import 'package:goribernetflix/widgets/label.dart';
import 'package:goribernetflix/widgets/wide_tile.dart';
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
      subtitle: movie.genres?.join(", "),
      description: movie.synopsis,
      imageUris: movie.imageUris,
      child: FutureBuilder2<List<MediaSource>>(
        future: Provider.of<FtpbdService>(context).getSources(id: movie.id),
        builder: (context, result) => result.maybeWhen(
          inProgress: () => const Center(
            child: CircularProgressIndicator(),
          ),
          success: (data) => _buildMovieSources(context, data),
          error: (error, _) => Center(
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
    return Builder(builder: (context) {
      return RoundedCard(
        title: "${source.displayName}, ${formatBytes(source.fileSize)}",
        subtitle: source.fileName,
        scrollAxis: Axis.horizontal,
        onTap: () async {
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
              await intent.launch();
            }
            final user = await Provider.of<UserService>(
              context,
              listen: false,
            ).getCurrentUser();
            if (user != null) {
              final isTraktActivated = await Provider.of<UserService>(
                context,
                listen: false,
              ).isTraktActivated(user.id);
              if (isTraktActivated) {
                await Future.delayed(const Duration(seconds: 2));
                await showWatchedDialog(context, user);
              }
            }
          } on UnsupportedError {
            print("It's the web!");
          } catch (e) {
            print(e);
          }
        },
      );
    });
  }

  Future<dynamic> showWatchedDialog(BuildContext context, User user) {
    Future<void> onPressed() async {
      {
        try {
          Provider.of<UserService>(
            context,
            listen: false,
          ).addToTraktHistory(
            MediaType.movie,
            user.id,
            ids: movie.externalIds,
          );
          Navigator.of(context).pop();
        } on ServerError catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
            ),
          );
        }
      }
    }

    return showAdaptiveDialog(
      context,
      title: "Did you finish watching the movie?",
      buttons: [
        ResponsiveButton(
          icon: FeatherIcons.x,
          label: "No, I didn't",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ResponsiveButton(
          icon: FeatherIcons.check,
          autofocus: true,
          label: "Yes, mark watched",
          onPressed: onPressed,
        ),
      ],
    );
  }

  List<List<Widget>> _buildMeta(BuildContext context) => [
        <Widget>[
          MetaLabel(movie.year.toString()),
          if (movie.criticRatings?.tmdb != null)
            MetaLabel(movie.criticRatings!.tmdb!.toString(),
                leading: const Icon(FeatherIcons.star)),
          if (movie.runtime != null)
            MetaLabel(
              prettyDuration(
                movie.runtime!,
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
            MetaLabel(
              movie.directors![0],
              title: "Director",
            ),
          if (movie.studios != null && movie.studios!.isNotEmpty)
            MetaLabel(
              movie.studios![0],
              title: "Production",
            ),
        ],
        [
          if (movie.cast != null)
            Expanded(
              child: MetaLabel(
                movie.cast!.take(10).map((i) => i.name).join(" • "),
                title: "Cast",
              ),
            ),
        ]
      ];
}
