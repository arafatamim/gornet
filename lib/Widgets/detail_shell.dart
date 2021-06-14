import 'package:chillyflix/Widgets/scrolling_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailShell extends StatefulWidget {
  final String title;
  final String? logoUrl;
  final List<String>? genres;
  final String? synopsis;
  final List<List<Widget>> meta;
  final Widget child;
  final Widget? continueWidget;
  final Widget? bottomWidget;

  DetailShell({
    required this.title,
    required this.meta,
    required this.child,
    this.logoUrl,
    this.genres,
    this.synopsis,
    this.continueWidget,
    this.bottomWidget,
  });

  @override
  _DetailShellState createState() => _DetailShellState();
}

class _DetailShellState extends State<DetailShell>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 5,
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: widget.logoUrl != null
                      ? FadeInImage.memoryNetwork(
                          image: widget.logoUrl!,
                          placeholder: kTransparentImage,
                        )
                      : Text(
                          widget.title,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                ),
                SizedBox(height: 20),
                for (final row in widget.meta) ...[
                  Row(children: row),
                  SizedBox(height: 10)
                ],
                if (widget.genres?.length != 0) ...[
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.genres!.join(", "),
                      style: GoogleFonts.sourceSansPro(
                        color: Colors.grey.shade400,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
                if (widget.synopsis != null) ...[
                  SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: ScrollingText(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        widget.synopsis.toString(),
                        softWrap: true,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1
                            ?.copyWith(height: 1.4),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                if (widget.continueWidget != null) widget.continueWidget!,
                if (widget.bottomWidget != null)
                  Expanded(child: widget.bottomWidget!),
              ],
            ),
          ),
          SizedBox(width: 50),
          Flexible(
            flex: 5,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
