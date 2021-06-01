import 'package:chillyflix/Widgets/buttons/animated_icon_button.dart';
import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:marquee/marquee.dart';

class Spotlight extends StatefulWidget {
  final String? id;
  final String? logo;
  final String? backdrop;
  final String title;
  final int? year;
  final String? synopsis;
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
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  late final FocusNode _node;

  @override
  void initState() {
    _node = FocusNode();
    _node.addListener(() {
      if (_node.hasFocus) {
        Scrollable.ensureVisible(context, alignment: 1);
      }
    });
    super.initState();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.logo != null
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 100),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: widget.logo!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headline3,
                    ),
              SizedBox(height: 20),
              if (widget.synopsis != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150, maxWidth: 500),
                  child: ScrollingText(
                    speed: 12,
                    child: Text(
                      widget.synopsis!,
                      style: Theme.of(context).textTheme.bodyText1?.apply(
                            heightFactor: 0.8,
                            fontSizeFactor: 1.2,
                            color: Colors.grey.shade400,
                          ),
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                  // child: Marquee(
                  //   text: widget.synopsis!,
                  //   scrollAxis: Axis.vertical,
                  //   style: Theme.of(context).textTheme.bodyText1?.apply(
                  //         heightFactor: 0.8,
                  //         fontSizeFactor: 1.2,
                  //         color: Colors.grey.shade400,
                  //       ),
                  //   fadingEdgeEndFraction: 0.1,
                  //   fadingEdgeStartFraction: 0.1,
                  //   startPadding: 110,
                  //   blankSpace: 30,
                  //   velocity: 15,
                  //   startAfter: Duration(seconds: 2),
                  //   pauseAfterRound: Duration(seconds: 2),
                  // ),
                ),
              SizedBox(height: 20),
              // MaterialButton(
              //   child: Icon(FeatherIcons.arrowRight),
              //   onPressed: widget.onTapDetails,
              //   focusColor: Colors.white.withAlpha(50),
              //   autofocus: true,
              //   focusElevation: 0,
              //   padding: EdgeInsets.all(28),
              //   minWidth: 0,
              //   // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   shape: CircleBorder(
              //     side: BorderSide(
              //       width: 1,
              //       color: Colors.white.withAlpha(50),
              //     ),
              //   ),
              // )
              AnimatedIconButton(
                icon: Icon(FeatherIcons.arrowRight),
                label: Text(
                  "Details",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onPressed: widget.onTapDetails,
              )
            ],
          ),
          if (widget.backdrop != null)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 8),
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
                ),
              ),
            )
        ],
      ),
    );
  }
}
