import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Services/FtpbdService.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

Widget coverListView(
  BuildContext context,
  String endpoint, {
  bool showIcon = false,
  VoidCallback? onRefresh,
}) {
  return FutureBuilder<List<SearchResult>>(
    future: Provider.of<FtpbdService>(context).search(endpoint, limit: 6),
    builder: (context, snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Center(child: CircularProgressIndicator());
        case ConnectionState.done:
          if (snapshot.hasData && snapshot.data?.length != 0) {
            final items = snapshot.data!;
            return OrientationBuilder(builder: (context, orientation) {
              int itemCount = orientation == Orientation.landscape ? 3 : 6;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: itemCount,
                  childAspectRatio: 0.55,
                ),
                itemCount: itemCount,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  SearchResult item = items[index];
                  return Cover(
                    searchResult: item,
                    showIcon: showIcon,
                    onTap: () {
                      Navigator.pushNamed(context, "/detail", arguments: item);
                    },
                  );
                },
              );
            });
          } else {
            return Center(
              child: buildError(
                snapshot.error?.toString() ?? "Error fetching data",
                onRefresh: onRefresh,
              ),
            );
          }
        default:
          return Container();
      }
    },
  );
}

class Cover extends StatefulWidget {
  final SearchResult searchResult;
  final bool showIcon;

  final Function onTap;
  final Function? onFocus;
  const Cover({
    Key? key,
    required this.searchResult,
    required this.showIcon,
    required this.onTap,
    this.onFocus,
  }) : super(key: key);

  @override
  _CoverState createState() => _CoverState();
}

class _CoverState extends State<Cover> with SingleTickerProviderStateMixin {
  late FocusNode _node;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _focusAlpha = 100;

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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(_focusAlpha),
                    blurRadius: 15,
                    offset: Offset(10, 15),
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
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        if (widget.searchResult.year != null)
                          Text(
                            widget.searchResult.year!.toString(),
                            style: GoogleFonts.sourceSansPro(
                              color: Colors.grey.shade300,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.showIcon) ...[
                    Spacer(),
                    Icon(
                      widget.searchResult.isMovie ? Icons.movie : Icons.tv,
                      color: Colors.white,
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
    _node = FocusNode();
    _node.addListener(_onFocusChange);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 100),
        vsync: this,
        lowerBound: 0.9,
        upperBound: 1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    super.initState();
  }

  void _onFocusChange() {
    Scrollable.ensureVisible(
      _node.context!,
      alignment: 1.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );

    if (_node.hasFocus) {
      _controller.forward();
      if (widget.onFocus != null) {
        widget.onFocus!();
      }
    } else {
      _controller.reverse();
    }
  }

  void _onTap() {
    _node.requestFocus();
    widget.onTap();
  }
}
