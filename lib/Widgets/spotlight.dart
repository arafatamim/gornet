import 'package:chillyflix/Widgets/buttons/animated_icon_button.dart';
import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:chillyflix/utils.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:transparent_image/transparent_image.dart';

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
  late final FocusNode _imageNode;
  Color _borderColor = Colors.transparent;

  @override
  void initState() {
    _node = FocusNode();
    _imageNode = FocusNode();

    _node.addListener(_nodeListener);
    _imageNode.addListener(_imageNodeListener);

    super.initState();
  }

  void _imageNodeListener() {
    setState(() {
      if (_imageNode.hasFocus)
        _borderColor = Colors.white;
      else
        _borderColor = Colors.transparent;
    });
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
    _imageNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      canRequestFocus: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.backdrop != null)
            Expanded(
              child: InkWell(
                focusNode: _imageNode,
                focusColor: Colors.transparent,
                onTap: widget.onTapDetails,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.fastLinearToSlowEaseIn,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(
                      width: 4.0,
                      color: _borderColor,
                      style: BorderStyle.solid,
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 8),
                        blurRadius: 12,
                        color: Colors.black.withAlpha(70),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.backdrop!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(width: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(height: 20),
              Row(
                children: _buildMeta(
                  ageRating: widget.ageRating,
                  endDate: widget.endDate,
                  hasEnded: widget.hasEnded,
                  rating: widget.rating,
                  runtime: widget.runtime,
                  year: widget.year,
                ),
              ),
              if (widget.genres != null) ...[
                SizedBox(height: 20),
                Text(
                  widget.genres!.join(", "),
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontSize: 22.0, color: Colors.grey.shade300),
                )
              ],
              // widget.logo != null
              //     ? ConstrainedBox(
              //         constraints: BoxConstraints(maxHeight: 100),
              //         child: FadeInImage.memoryNetwork(
              //           placeholder: kTransparentImage,
              //           image: widget.logo!,
              //           fit: BoxFit.cover,
              //         ),
              //       )
              //     : Text(
              //         widget.title,
              //         style: Theme.of(context).textTheme.headline3,
              //       ),
              SizedBox(height: 20),
              if (widget.synopsis != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 250, maxWidth: 550),
                  child: ScrollingText(
                    speed: 12,
                    child: Text(
                      widget.synopsis!,
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: Colors.grey.shade300,
                            height: 1.1,
                          ),
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                ),
              // SizedBox(height: 20),
              // AnimatedIconButton(
              //   icon: Icon(FeatherIcons.arrowRight),
              //   label: Text(
              //     "Details",
              //     style: Theme.of(context).textTheme.bodyText1,
              //   ),
              //   onPressed: widget.onTapDetails,
              // )
            ],
          ),
        ],
      ),
    );
  }

  final _buildMeta = ({
    num? rating,
    Duration? runtime,
    String? ageRating,
    int? year,
    bool? hasEnded,
    DateTime? endDate,
  }) =>
      <Widget>[
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
