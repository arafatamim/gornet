import 'package:cached_network_image/cached_network_image.dart';
import 'package:goribernetflix/Widgets/buttons/animated_icon_button.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:goribernetflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Spotlight extends StatefulWidget {
  final String? id;
  final String? logo;
  final String? backdrop;
  final String title;
  final int? year;
  final String? synopsis;
  final num? rating;
  final Duration? runtime;
  final String? ageRating;
  final bool? hasEnded;
  final DateTime? endDate;
  final List<String>? genres;
  final VoidCallback? onTapDetails;

  const Spotlight({
    this.backdrop,
    this.genres,
    this.id,
    this.logo,
    this.synopsis,
    required this.title,
    required this.onTapDetails,
    this.year,
    this.rating,
    this.runtime,
    this.ageRating,
    this.hasEnded,
    this.endDate,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  late final FocusNode _node;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(_nodeListener);

    super.initState();
  }

  void _nodeListener() {
    if (_node.hasFocus) {
      Scrollable.ensureVisible(
        context,
        alignment: 1,
      );
    }
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      canRequestFocus: false,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent],
              ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withAlpha(70),
                  BlendMode.darken,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.backdrop!,
                  fit: BoxFit.fitWidth,
                  alignment: const Alignment(0.0, -0.5),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.logo != null
                        ? (isSvg(widget.logo!)
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 150,
                                  maxWidth: 500,
                                ),
                                child: SvgPicture.network(
                                  widget.logo!,
                                  color: Colors.grey.shade50,
                                  colorBlendMode: BlendMode.srcIn,
                                  alignment: Alignment.bottomLeft,
                                ),
                              )
                            : CachedNetworkImage(
                                imageBuilder: (context, imageProvider) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                      ),
                                      child: Image(
                                        image: imageProvider,
                                      ),
                                    ),
                                  );
                                },
                                imageUrl: widget.logo!,
                                fadeInDuration:
                                    const Duration(milliseconds: 150),
                                errorWidget: (context, url, error) =>
                                    headlineText,
                                fit: BoxFit.scaleDown,
                              ))
                        : Text(
                            widget.title,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                    const SizedBox(height: 20),
                    Row(
                      children: _buildMeta(
                        ageRating: widget.ageRating,
                        endDate: widget.endDate,
                        hasEnded: widget.hasEnded,
                        rating: widget.rating,
                        year: widget.year,
                        genres: widget.genres,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (widget.synopsis != null)
                      ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 250, maxWidth: 550),
                        child: ScrollingText(
                          speed: 12,
                          child: Text(
                            widget.synopsis!,
                            style:
                                Theme.of(context).textTheme.bodyText1?.copyWith(
                                      color: Colors.grey.shade300,
                                      height: 1.1,
                                    ),
                          ),
                          scrollDirection: Axis.vertical,
                        ),
                      ),
                    const SizedBox(height: 15),
                    AnimatedIconButton(
                      icon: const Icon(FeatherIcons.play),
                      label: Text(
                        "Watch",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      onPressed: widget.onTapDetails,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget get headlineText => Align(
        alignment: Alignment.topLeft,
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      );

  final _buildMeta = ({
    num? rating,
    Duration? runtime,
    String? ageRating,
    int? year,
    bool? hasEnded,
    DateTime? endDate,
    List<String>? genres,
  }) =>
      <Widget>[
        if (genres != null) buildLabel(genres.join(", ")),
        if (rating != null)
          buildLabel(
            rating.toStringAsFixed(2),
            icon: FeatherIcons.star,
          ),
        if (runtime != null)
          buildLabel(
            prettyDuration(
              runtime,
              tersity: DurationTersity.minute,
              abbreviated: true,
              delimiter: " ",
            ),
            icon: FeatherIcons.clock,
          ),
        if (ageRating != null) buildLabel(ageRating, hasBackground: true),
        if (year != null)
          buildLabel(
            year.toString() +
                (hasEnded != null
                    ? (hasEnded
                        ? (endDate != null
                            ? (endDate.year == year
                                ? ""
                                : " - " + endDate.year.toString())
                            : " - ENDED")
                        : " - PRESENT")
                    : ""),
          ),
      ];
}
