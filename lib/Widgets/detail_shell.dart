import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';

class DetailShell extends StatefulWidget {
  final String title;
  final String? logoUrl;
  final List<String>? genres;
  final String? synopsis;
  final List<Widget> meta;
  final Widget child;
  final Widget? continueWidget;

  DetailShell({
    required this.title,
    this.logoUrl,
    this.genres,
    this.synopsis,
    this.continueWidget,
    required this.meta,
    required this.child,
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
                Row(children: widget.meta),
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
                  Expanded(
                    child: Text(
                      widget.synopsis.toString(),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
                SizedBox(height: 20),
                if (widget.continueWidget != null) widget.continueWidget!,
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
