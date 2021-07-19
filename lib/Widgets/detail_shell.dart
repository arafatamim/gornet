import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goribernetflix/Widgets/scrolling_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:goribernetflix/utils.dart';

class DetailShell extends StatefulWidget {
  final String title;
  final String? logoUrl;
  final List<String>? genres;
  final String? synopsis;
  final List<List<Widget>> meta;
  final Widget child;
  final Widget? continueWidget;
  final Widget? bottomWidget;

  const DetailShell({
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
    final mainLayout = <Widget>[
      Flexible(
        flex: 5,
        child: Column(
          children: <Widget>[
            widget.logoUrl != null
                ? isSvg(widget.logoUrl!)
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: SvgPicture.network(
                            widget.logoUrl!,
                            height: 150,
                            color: Colors.grey.shade50,
                            colorBlendMode: BlendMode.srcIn,
                            alignment: Alignment.topLeft,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageBuilder: (context, imageProvider) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: Image(image: imageProvider),
                            ),
                          );
                        },
                        imageUrl: widget.logoUrl!,
                        fadeInDuration: const Duration(milliseconds: 150),
                        errorWidget: (context, url, error) => headlineText,
                        fit: BoxFit.scaleDown,
                      )
                : headlineText,
            const SizedBox(height: 20),
            for (final row in widget.meta) ...[
              Row(children: row),
              const SizedBox(height: 10)
            ],
            if (widget.genres != null && widget.genres!.isNotEmpty) ...[
              const SizedBox(height: 10),
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
              const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            if (widget.continueWidget != null) widget.continueWidget!,
            if (widget.bottomWidget != null)
              Expanded(child: widget.bottomWidget!),
          ],
        ),
      ),
      const SizedBox(width: 50, height: 50),
      Flexible(
        flex: 5,
        child: widget.child,
      ),
    ];

    return Padding(
        padding: const EdgeInsets.all(50.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: mainLayout,
              );
            } else {
              return const Center(
                child: Text("Rotate screen"),
              );
            }
          },
        ));
  }

  Widget get headlineText => Align(
        alignment: Alignment.topLeft,
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      );
}
