import 'package:chillyflix/Models/FtpbdModel.dart';
import 'package:chillyflix/Widgets/RoundedCard.dart';
import 'package:chillyflix/Widgets/shimmers.dart';
import 'package:chillyflix/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';

class CoverListViewBuilder extends StatefulWidget {
  final Future<List<SearchResult>> results;
  final bool showIcon;
  final bool separator;

  const CoverListViewBuilder(
      {required this.results, this.showIcon = false, this.separator = true});

  @override
  State<CoverListViewBuilder> createState() => _CoverListViewBuilderState();
}

class _CoverListViewBuilderState extends State<CoverListViewBuilder> {
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
              return CoverListView(
                items,
                separator: widget.separator,
              );
              /*
              return OrientationBuilder(builder: (context, orientation) {
                int itemCount = orientation == Orientation.landscape ? 3 : 5;
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
                      title: item.name,
                      subtitle: (item.year ?? "").toString(),
                      image: item.imageUris?.primary ??
                          item.imageUris?.thumb ??
                          item.imageUris?.backdrop,
                      style: RoundedCardStyle(
                        primaryColor: Colors.transparent,
                        textColor: Colors.grey.shade300,
                        focusTextColor: Colors.white,
                        mutedTextColor: Colors.grey.shade400,
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
              });*/
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

class CoverListView extends StatelessWidget {
  final List<SearchResult> items;
  final bool showIcon;
  final bool separator;
  const CoverListView(this.items,
      {this.showIcon = false, this.separator = true});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: true,
      itemCount: items.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => SizedBox(width: separator ? 12 : 0),
      itemBuilder: (BuildContext context, int index) {
        SearchResult item = items[index];
        return AspectRatio(
          aspectRatio: 0.6,
          child: Cover(
            title: item.name,
            subtitle: (item.year ?? "").toString(),
            image: item.imageUris?.primary,
            icon: showIcon
                ? (item.isMovie ? FeatherIcons.film : FeatherIcons.tv)
                : null,
            style: RoundedCardStyle(
              primaryColor: Colors.transparent,
              textColor: Colors.grey.shade300,
              focusTextColor: Colors.white,
              mutedTextColor: Colors.grey.shade400,
              focusMutedTextColor: Colors.grey.shade300,
            ),
            onTap: () {
              Navigator.pushNamed(context, "/detail", arguments: item);
            },
          ),
        );
      },
    );
  }
}

class Cover extends StatefulWidget {
  final String? image;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final RoundedCardStyle style;
  final Function onTap;
  final Function? onFocus;

  const Cover({
    Key? key,
    this.image,
    required this.title,
    required this.subtitle,
    this.icon,
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
        widget.key,
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
              child: buildPosterImage(),
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
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: GoogleFonts.sourceSansPro(
                            color: _textColor,
                            fontSize: 20,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!.toString(),
                            style: GoogleFonts.sourceSansPro(
                              color: _mutedTextColor,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.icon != null) ...[
                    Spacer(),
                    Icon(
                      widget.icon!,
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

  Widget buildPosterImage() {
    return Container(
      child: (widget.image != null)
          ? FadeInImage.memoryNetwork(
              key: Key(widget.image!),
              placeholder: kTransparentImage,
              image: widget.image!,
              fit: BoxFit.cover,
            )
          : ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    focal: Alignment(0, 0),
                    focalRadius: 1,
                    radius: 0.5,
                    center: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '${widget.title} (${widget.subtitle})'.toUpperCase(),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText1?.apply(
                              color: Colors.grey.shade400,
                              fontSizeFactor: 1.3,
                              heightFactor: 0.7,
                            ),
                      ),
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
