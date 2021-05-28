import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/shimmers.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';

class CoverListView extends StatefulWidget {
  final Future<List<SearchResult>> results;
  final bool showIcon;

  const CoverListView({required this.results, this.showIcon = false});

  @override
  State<CoverListView> createState() => _CoverListViewState();
}

class _CoverListViewState extends State<CoverListView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SearchResult>>(
      future: widget.results,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return ShimmerList(itemCount: 6);
          case ConnectionState.done:
            if (snapshot.hasData && snapshot.data?.length != 0) {
              final items = snapshot.data!;
              return OrientationBuilder(builder: (context, orientation) {
                int itemCount = orientation == Orientation.landscape ? 3 : 6;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: itemCount,
                    childAspectRatio: 0.5,
                  ),
                  itemCount: itemCount,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    SearchResult item = items[index];
                    return Cover(
                      searchResult: item,
                      showIcon: widget.showIcon,
                      style: RoundedCardStyle(
                        primaryColor: Colors.transparent,
                        textColor: Colors.grey.shade400,
                        focusTextColor: Colors.white,
                        mutedTextColor: Colors.grey.shade600,
                        focusMutedTextColor: Colors.grey.shade300,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          "/detail",
                          arguments: item,
                        );
                      },
                    );
                  },
                );
              });
            } else {
              return Center(
                child: buildError(
                  snapshot.error?.toString() ?? "Error fetching data",
                  onRefresh: () => setState(() {}),
                ),
              );
            }
          default:
            return Container();
        }
      },
    );
  }
}

class Cover extends StatefulWidget {
  final SearchResult searchResult;
  final bool showIcon;
  final RoundedCardStyle style;
  final Function onTap;
  final Function? onFocus;

  const Cover({
    Key? key,
    required this.searchResult,
    required this.showIcon,
    required this.onTap,
    this.style = const RoundedCardStyle(),
    this.onFocus,
  }) : super(key: key);

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _focusAlpha = 60;
  late Color _primaryColor;
  late Color _textColor;
  late Color _mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: ValueKey(
        widget.searchResult,
      ), // Necessary otherwise image doesn't change
      onPressed: _onTap,
      focusNode: _node,
      focusColor: Colors.transparent,
      focusElevation: 0,
      child: buildCover(context),
    );

    // return Focus(
    //     focusNode: _node,
    //     onKey: _onKey,
    //     child: Builder(
    //       builder: (context) {
    //         return buildCover(context);
    //       }
    //     ),
    // );
  }

  Widget buildCover(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _onTap,
        child: Column(
          children: <Widget>[
            Container(
              child: buildPosterImage(context, widget.searchResult.imageUris),
              decoration: BoxDecoration(
                border: Border.all(width: 4, color: _primaryColor),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(_focusAlpha),
                    blurRadius: 15,
                    offset: Offset(2, 10),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.searchResult.name,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.sourceSansPro(
                            color: _textColor,
                            fontSize: 20,
                          ),
                        ),
                        if (widget.searchResult.year != null)
                          Text(
                            widget.searchResult.year!.toString(),
                            style: GoogleFonts.sourceSansPro(
                              color: _mutedTextColor,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.showIcon) ...[
                    Spacer(),
                    Icon(
                      widget.searchResult.isMovie
                          ? FeatherIcons.film
                          : FeatherIcons.tv,
                      color: _mutedTextColor,
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPosterImage(BuildContext context, ImageUris? imageUris) {
    return Container(
      child: (imageUris != null && imageUris.primary != null)
          ? FadeInImage.memoryNetwork(
              key: Key(imageUris.primary!),
              placeholder: kTransparentImage,
              image: imageUris.primary!,
              fit: BoxFit.cover,
            )
          : ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Container(
                decoration: BoxDecoration(color: Colors.blue.shade900),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.searchResult.name} (${widget.searchResult.year})',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                          fontSize: 24, color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),
            ),
      height: 350.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  // void _openDetails() {
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(widget.item)));
  // }

  // bool _onKey(FocusNode node, RawKeyEvent event) {
  //   if(event is RawKeyDownEvent) {
  //     if(event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
  //       _onTap();
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  //   return false;
  // }

  @override
  void initState() {
    _primaryColor = widget.style.primaryColor;
    _textColor = widget.style.textColor;
    _mutedTextColor = widget.style.mutedTextColor;
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.98,
      upperBound: 1,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    super.initState();
  }

  void _onFocusChange() {
    if (_node.context != null)
      Scrollable.ensureVisible(
        _node.context!,
        alignment: 1.0,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );

    if (_node.hasFocus) {
      _controller.forward();
      setState(() {
        _primaryColor = widget.style.focusPrimaryColor;
        _textColor = widget.style.focusTextColor;
        _mutedTextColor = widget.style.focusMutedTextColor;
      });
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _controller.reverse();
      setState(() {
        _primaryColor = widget.style.primaryColor;
        _textColor = widget.style.textColor;
        _mutedTextColor = widget.style.mutedTextColor;
      });
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap();
  }
}
